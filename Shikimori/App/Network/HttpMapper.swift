//
// Created by Aziz L on 26.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation


class HttpMapper<T> {

    enum HttpMapperError: Error {
        case NotImplemented
    }

    func decode(_ data: Data) throws -> T { throw HttpMapperError.NotImplemented }
}