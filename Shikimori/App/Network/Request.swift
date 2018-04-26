//
// Created by Aziz L on 26.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation


protocol Request {
    associatedtype T
    func getPromise() -> Promise<T>?

    func load() -> Promise<T>
    func cancel()
}
