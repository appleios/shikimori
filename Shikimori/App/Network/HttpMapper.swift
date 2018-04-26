//
// Created by Aziz Latipov on 26.04.2018.
// Copyright (c) 2018 shikimori.org. All rights reserved.
//

import Foundation


class HttpMapper<T> {
    enum HttpMapperError: Error {
        case NotImplemented
    }
    func map(_ data: Data) throws -> T { throw HttpMapperError.NotImplemented }
}