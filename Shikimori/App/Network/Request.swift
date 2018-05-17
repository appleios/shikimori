//
// Created by Aziz L on 26.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation

protocol Request {
    associatedtype T

    func load() -> Promise<T> // TODO: must be called once
    func cancel()
}
