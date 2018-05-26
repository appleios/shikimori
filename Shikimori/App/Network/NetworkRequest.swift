//
// Created by Aziz L on 26.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation


protocol NetworkRequest {
    associatedtype T

    mutating func load() -> Promise<T>

    func isLoading() -> Bool

    mutating func cancel()

    func getResult() -> Promise<T>?
}
