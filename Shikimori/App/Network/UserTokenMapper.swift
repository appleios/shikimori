//
// Created by Aziz Latipov on 26.04.2018.
// Copyright (c) 2018 shikimori.org. All rights reserved.
//

import Foundation


class UserTokenMapper: HttpMapper<UserToken> {

    struct Result: Codable {
        var accessToken: String
        var refreshToken: String
        var createdAt: Date
        var expiresIn: Int
        var tokenType: String
    }

    let decoder: JSONDecoder

    init(decoder: JSONDecoder) {
        self.decoder = decoder
        super.init()
    }

    override func map(_ data: Data) throws -> UserToken {
        let result = try decoder.decode(Result.self, from: data)
        return UserToken(accessToken: result.accessToken,
                refreshToken: result.refreshToken,
                createdAt: result.createdAt,
                expireDate: result.createdAt + TimeInterval(result.expiresIn),
                tokenType: UserToken.TokenType(rawValue: result.tokenType)!)
    }

}