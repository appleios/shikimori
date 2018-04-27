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

        let sal = ServiceAccessLayer()
        let mapper = UserTokenMapper(jsonDecoder: sal.jsonDecoder)
        let data = """
        {
        "access_token":"ACCESS_TOKEN",
        "token_type":"bearer",
        "expires_in":86400,
        "refresh_token":"REFRESH_TOKEN",
        "created_at":1524749533
        }
        """.data(using: .utf8)
        let result: SessionToken = try! mapper.decode(data!)

        XCTAssertNotNil(result)
        XCTAssertEqual(result.accessToken, "ACCESS_TOKEN")
        XCTAssertEqual(result.refreshToken, "REFRESH_TOKEN")
        XCTAssertEqual(result.tokenType, SessionToken.TokenType.bearer)
    }

    func testWhoami() {
        let sal = ServiceAccessLayer()
        let mapper = AccountMapper(jsonDecoder: sal.jsonDecoder)

        let avatar = "https://host.com/avatar"
        let data = """
        {
            "avatar": \"\(avatar)\",
            "birth_on": null,
            "id": 12345,
            "image": {
                "x148": "",
                "x16":  "",
                "x160": "",
                "x32":  "",
                "x48":  "",
                "x64":  "",
                "x80":  ""
            },
            "last_online_at": "2018-04-27T04:31:42.014+03:00",
            "locale": "ru",
            "name": null,
            "nickname": "NICKNAME",
            "sex": null,
            "website": null
        }
        """.data(using: .utf8)
        let result: Account = try! mapper.decode(data!)

        XCTAssertNotNil(result)
        XCTAssertEqual(result.id, 12345)
        XCTAssertEqual(result.nickname, "NICKNAME")
        XCTAssertEqual(result.avatar, URL(string: avatar))
    }

}
