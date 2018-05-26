//
// Created by Aziz L on 25.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation
@testable import Shikimori
import XCTest

class TokenRequestTests: XCTestCase {

    func testUserTokenMapper() {
        let fixture = """
        {
        "access_token":"ACCESS_TOKEN",
        "token_type":"bearer",
        "expires_in":86400,
        "refresh_token":"REFRESH_TOKEN",
        "created_at":1524749533
        }
        """
        guard let data = fixture.data(using: .utf8) else {
            XCTFail("Incorrect fixture")
            return
        }

        let mapper = TokenRequestResultMapper()
        var result: SessionToken
        do {
            result = try mapper.mapToDomain(data)
        } catch {
            XCTFail("Mapping result is nil")
            return
        }

        XCTAssertEqual(result.accessToken, "ACCESS_TOKEN")
        XCTAssertEqual(result.refreshToken, "REFRESH_TOKEN")
        XCTAssertEqual(result.tokenType, SessionToken.TokenType.bearer)
    }

    func testWhoami() {
        let fixture = """
        {
            "id": 12345,
            "nickname": "NICKNAME",
            "avatar": null
        }
        """
        guard let data = fixture.data(using: .utf8) else {
            XCTFail("Incorrect fixture")
            return
        }

        var result: Account
        do{
            let mapper = AccountRequestResultMapper()
            result = try mapper.mapToDomain(data)
        } catch {
            XCTFail("Mapping result is nil")
            return
        }

        XCTAssertEqual(result.user.id, 12_345)
    }

}
