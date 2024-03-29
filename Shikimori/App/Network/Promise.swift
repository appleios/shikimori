//
// Created by Aziz L on 25.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation

class Promise<T> {
    typealias ThenHandler = (T) -> Void
    typealias ErrorHandler = (Error?) -> Void
    typealias CompleteHandler = () -> Void

    enum State {
        case pending
        case fulfilled(value: T)
        case error(error: Error?)
    }

    private (set) var state: State

    private var thenDeps: [ThenHandler]
    private var errorDeps: [ErrorHandler]

    private var lock: NSLock

    func isPending() -> Bool {
        switch state {
        case .pending:
            return true
        default:
            return false
        }
    }

    func isFulfilled() -> Bool {
        switch state {
        case .fulfilled:
            return true
        default:
            return false
        }
    }

    func isError() -> Bool {
        switch state {
        case .error:
            return true
        default:
            return false
        }
    }

    func isResolved() -> Bool {
        switch state {
        case .fulfilled:
            return true
        case .error:
            return true
        default:
            return false
        }
    }

    func isCancelled() -> Bool {
        switch state {
        case .fulfilled:
            return true
        case .error(let e):
            return e == nil
        default:
            return false
        }
    }

    var value: T? {
        switch state {
        case let .fulfilled(value):
            return value
        default:
            return nil
        }
    }

    var error: Error? {
        switch state {
        case let .error(error):
            return error
        default:
            return nil
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

    func reject(_ error: Error?) {
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
        reject(nil)
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

        case .error:
            lock.unlock()
        }
    }

    func error(_ block: @escaping ErrorHandler) {
        lock.lock()
        switch state {
        case .pending:
            errorDeps.append(block)
            lock.unlock()

        case .fulfilled:
            lock.unlock()

        case .error(let error):
            lock.unlock()
            block(error)
        }
    }

    func complete(_ block: @escaping CompleteHandler) {
        lock.lock()
        switch state {
        case .pending:
            let thenHandler: (T) -> Void = { _ in block() }
            let errorHandler: (Error?) -> Void = { _ in block() }
            thenDeps.append(thenHandler)
            errorDeps.append(errorHandler)
            lock.unlock()

        case .fulfilled:
            lock.unlock()
            block()

        case .error:
            lock.unlock()
            block()
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
        }
    }
}

extension Promise {

    var chained: Promise<T> {
        let p = Promise<T>()
        self.chain(p)
        return p
    }

}

// TODO when([ p1, p2 ])
