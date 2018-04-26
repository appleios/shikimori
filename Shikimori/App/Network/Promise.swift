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
    private var completeDeps: [CompleteHandler]

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
        completeDeps = []
    }

    init(withValue value: T) {
        lock = NSLock()
        state = .fulfilled(value: value)
        thenDeps = []
        errorDeps = []
        completeDeps = []
    }

    init(withError error: Error) {
        lock = NSLock()
        state = .error(error: error)
        thenDeps = []
        errorDeps = []
        completeDeps = []
    }

    func fulfill(value: T) {
        guard isPending() else { return }

        lock.lock()
        state = .fulfilled(value: value)
        let thens = thenDeps
        let completes = completeDeps
        lock.unlock()

        thenDeps = []
        errorDeps = []
        completeDeps = []

        for block in thens {
            block(value)
        }
        for block in completes {
            block()
        }
    }

    func reject(error: Error) {
        guard isPending() else { return }

        lock.lock()
        state = .error(error: error)
        let errors = errorDeps
        let completes = completeDeps
        lock.unlock()

        thenDeps = []
        errorDeps = []
        completeDeps = []

        for block in errors {
            block(error)
        }
        for block in completes {
            block()
        }
    }

    func cancel() {
        guard isPending() else { return }

        lock.lock()
        state = .cancelled
        let completes = completeDeps
        lock.unlock()

        thenDeps = []
        errorDeps = []
        completeDeps = []

        for block in completes {
            block()
        }
    }

    func then(_ block: @escaping ThenHandler) {
        switch state {
        case .pending:
            lock.lock()
            thenDeps.append(block)
            lock.unlock()

        case .fulfilled(let value):
            block(value)
        case .error(_): break
        case .cancelled: break
        }
    }

    func error(_ block: @escaping ErrorHandler) {
        switch state {
        case .pending:
            lock.lock()
            errorDeps.append(block)
            lock.unlock()

        case .fulfilled(_): break
        case .error(let error): block(error)
        case .cancelled: break
        }
    }

    func complete(_ block: @escaping CompleteHandler) {
        switch state {
        case .pending:
            lock.lock()
            completeDeps.append(block)
            lock.unlock()

        case .fulfilled(_): block()
        case .error(_): block()
        case .cancelled: break
        }
    }
}
