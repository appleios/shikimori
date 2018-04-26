//
// Created by Aziz Latipov on 25.04.2018.
// Copyright (c) 2018 shikimori.org. All rights reserved.
//

import Foundation


class Promise<T>
{
    typealias ThenHandler = (T) -> ()
    typealias ErrorHandler = (Error) -> ()
    typealias CompleteHandler = () -> ()

    private enum State {
        case pending
        case fulfilled(value: T)
        case error(error: Error)
        case cancelled
    }

    private var state: State

    private var thenDeps: [ThenHandler]
    private var errorDeps: [ErrorHandler]

    private var lock: NSLock

    func isPending() -> Bool {
        switch state {
        case .pending: return true
        default: return false
        }
    }

    func isFulfilled() -> Bool {
        switch state {
        case .fulfilled(_): return true
        default: return false
        }
    }

    func isError() -> Bool {
        switch state {
        case .error(_): return true
        default: return false
        }
    }

    func isCancelled() -> Bool {
        switch state {
        case .cancelled: return true
        default: return false
        }
    }

    func value() -> T? {
        switch state {
        case let .fulfilled(value): return value
        default: return nil
        }
    }

    func error() -> Error? {
        switch state {
        case let .error(error): return error
        default: return nil
        }
    }

    init() {
        lock = NSLock()
        state = .pending
        thenDeps = []
        errorDeps = []
    }

    init(withValue value: T) {
        lock = NSLock()
        state = .fulfilled(value: value)
        thenDeps = []
        errorDeps = []
    }

    init(withError error: Error) {
        lock = NSLock()
        state = .error(error: error)
        thenDeps = []
        errorDeps = []
    }

    func fulfill(_ value: T) {
        lock.lock()
        guard isPending() else {
            lock.unlock()
            return
        }

        state = .fulfilled(value: value)
        let thens = thenDeps
        thenDeps = []
        errorDeps = []
        lock.unlock()

        for block in thens {
            block(value)
        }
    }

    func reject(_ error: Error) {
        lock.lock()
        guard isPending() else {
            lock.unlock()
            return
        }

        state = .error(error: error)
        let errors = errorDeps
        thenDeps = []
        errorDeps = []
        lock.unlock()

        for block in errors {
            block(error)
        }
    }

    func cancel() {
        lock.lock()
        guard isPending() else {
            lock.unlock()
            return
        }

        state = .cancelled
        thenDeps = []
        errorDeps = []
        lock.unlock()
    }

    func then(_ block: @escaping ThenHandler) {
        lock.lock()
        switch state {
        case .pending:
            thenDeps.append(block)
            lock.unlock()

        case .fulfilled(let value):
            lock.unlock()
            block(value)

        case .error(_):
            lock.unlock()
            break

        case .cancelled:
            lock.unlock()
            break
        }
    }

    func error(_ block: @escaping ErrorHandler) {
        lock.lock()
        switch state {
        case .pending:
            errorDeps.append(block)
            lock.unlock()

        case .fulfilled(_):
            lock.unlock()
            break

        case .error(let error):
            lock.unlock()
            block(error)

        case .cancelled:
            lock.unlock()
            break
        }
    }

    func complete(_ block: @escaping CompleteHandler) {
        lock.lock()
        switch state {
        case .pending:
            let thenHandler: (T) -> () = { _ in block() }
            let errorHandler: (Error) -> () = { _ in block() }
            thenDeps.append(thenHandler)
            errorDeps.append(errorHandler)
            lock.unlock()

        case .fulfilled(_):
            lock.unlock()
            block()

        case .error(_):
            lock.unlock()
            block()

        case .cancelled:
            lock.unlock()
            break
        }
    }

    func chain(_ promise: Promise<T>) {
        let thenHandler = { promise.fulfill($0) }
        let errorHandler = { promise.reject($0) }

        lock.lock()
        switch state {
        case .pending:
            thenDeps.append(thenHandler)
            errorDeps.append(errorHandler)
            lock.unlock()

        case .fulfilled(let value):
            lock.unlock()
            thenHandler(value)

        case .error(let error):
            lock.unlock()
            errorHandler(error)

        case .cancelled:
            lock.unlock()
            break
        }
    }
}
