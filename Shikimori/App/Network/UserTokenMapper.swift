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

        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case refreshToken = "refresh_token"
            case createdAt = "created_at"
            case expiresIn = "expires_in"
            case tokenType = "token_type"
        }

//        init(from decoder: Decoder) throws {
//            let container = try decoder.container(keyedBy: CodingKeys.self)
//            accessToken = try container.decode(String.self, forKey: .accessToken)
//            refreshToken = try container.decode(String.self, forKey: .refreshToken)
//            createdAt = try container.decode(Date.self, forKey: .createdAt)
//            expiresIn = try container.decode(Int.self, forKey: .expiresIn)
//            tokenType = try container.decode(String.self, forKey: .tokenType)
//        }
    }

    let decoder: JSONDecoder

    init(decoder: JSONDecoder) {
        self.decoder = decoder
        super.init()
    }

    override func map(_ data: Data) -> UserToken? {
        do {
            let result = try decoder.decode(Result.self, from: data)
            return UserToken(accessToken: result.accessToken,
                    refreshToken: result.refreshToken,
                    createdAt: result.createdAt,
                    expireDate: result.createdAt + TimeInterval(result.expiresIn),
                    tokenType: UserToken.TokenType(rawValue: result.tokenType)!)
        } catch {
            print("Unexpected error: \(error), while decoding: \(String(data: data, encoding: .utf8))")
        }
        return nil
    }

}