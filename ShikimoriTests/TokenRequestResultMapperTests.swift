//
// Created by Aziz L on 25.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation
@testable import Shikimori
import XCTest

class TokenRequestTests: BaseMappingTests {

    func testUserTokenMapper() {
        let data = fixture(body: """
        {
        "access_token":"ACCESS_TOKEN",
        "token_type":"bearer",
        "expires_in":86400,
        "refresh_token":"REFRESH_TOKEN",
        "created_at":1524749533
        }
        """)

        let result: SessionToken = tryMapping(TokenRequestResultMapper(), data: data)

        XCTAssertEqual(result.accessToken, "ACCESS_TOKEN")
        XCTAssertEqual(result.refreshToken, "REFRESH_TOKEN")
        XCTAssertEqual(result.tokenType, SessionToken.TokenType.bearer)
    }

}
