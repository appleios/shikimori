//
//  ShikimoriTests.swift
//  ShikimoriTests
//
//  Created by Aziz L on 25.04.2018.
//  Copyright © 2018 Aziz L. All rights reserved.
//

import XCTest
import Foundation
@testable import Shikimori


class ShikimoriTests: XCTestCase {

    func testUserTokenMapper() {
        let data = """
        {
        "access_token":"ACCESS_TOKEN",
        "token_type":"bearer",
        "expires_in":86400,
        "refresh_token":"REFRESH_TOKEN",
        "created_at":1524749533
        }
        """.data(using: .utf8)

        let mapper = TokenRequestResultMapper()
        let result: SessionToken = try! mapper.mapToDomain(data!)

        XCTAssertNotNil(result)
        XCTAssertEqual(result.accessToken, "ACCESS_TOKEN")
        XCTAssertEqual(result.refreshToken, "REFRESH_TOKEN")
        XCTAssertEqual(result.tokenType, SessionToken.TokenType.bearer)
    }

    func testWhoami() {
        let data = """
        {
            "id": 12345,
            "nickname": "NICKNAME",
            "avatar": null
        }
        """.data(using: .utf8)

        let mapper = AccountRequestResultMapper()
        let result: Account = try mapper.mapToDomain(data!)

        XCTAssertNotNil(result)
        XCTAssertEqual(result.user.id, 12345)
    }

}
