//
// Created by Aziz Latipov on 26.04.2018.
// Copyright (c) 2018 shikimori.org. All rights reserved.
//

import Foundation


protocol Request {
    associatedtype T
    var promise: Promise<T>? { get }

    func execute()
    func cancel()
}
