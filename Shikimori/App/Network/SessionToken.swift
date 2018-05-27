//
// Created by Aziz L on 26.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation

struct SessionToken: Codable, Equatable {

    enum TokenType: String, Codable {
        case bearer
    }

    let accessToken: String
    let refreshToken: String
    let createdAt: Date
    let expireDate: Date
    let tokenType: TokenType

    func isExpired(now: Date = Date()) -> Bool {
        return now.timeIntervalSince(expireDate) >= 0
    }

    static func ==(lhs: SessionToken, rhs: SessionToken) -> Bool {
        return lhs.accessToken == rhs.accessToken
                && lhs.refreshToken == rhs.refreshToken
                && lhs.createdAt == rhs.createdAt
                && lhs.expireDate == rhs.expireDate
                && lhs.tokenType == rhs.tokenType
    }
}
