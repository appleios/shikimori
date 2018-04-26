//
// Created by Aziz L on 26.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation


struct UserToken {

    enum TokenType: String {
        case bearer = "bearer"
    }

    let accessToken: String
    let refreshToken: String
    let createdAt: Date
    let expireDate: Date
    let tokenType: TokenType
}
