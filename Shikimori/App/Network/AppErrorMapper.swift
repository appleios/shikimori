//
// Created by Aziz Latipov on 26.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation


class AppErrorMapper {

    struct Result: Codable {
        var error: String
        var errorDescription: String
    }

    let jsonDecoder: JSONDecoder

    init(jsonDecoder: JSONDecoder) {
        self.jsonDecoder = jsonDecoder
    }

    func decode(_ data: Data) throws -> AppError {
        let result = try jsonDecoder.decode(Result.self, from: data)

        switch result.error {
        case "invalid_grant":
            return AppError.invalidGrant(description: result.errorDescription)
        case "invalid_token":
            return AppError.invalidToken(description: result.errorDescription)
        default:
            return AppError.unknown(code: result.error, description: result.errorDescription)
        }
    }

}
