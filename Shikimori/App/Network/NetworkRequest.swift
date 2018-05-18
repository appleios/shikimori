//
// Created by Aziz L on 26.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation


enum NetworkRequestError: Error {
    case alreadyLoading
}


/// Generic protocol for network requests (e.g. HTTP, FTP, etc)
protocol NetworkRequest {
    associatedtype T

    mutating func load() throws -> Promise<T>

    func isLoading() -> Bool

    mutating func cancel()

    func getResult() -> Promise<T>?
}
