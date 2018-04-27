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

        let sal = ServiceAccessURLRequestFactory()
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
        let result: UserToken = try! mapper.decode(data!)

        XCTAssertNotNil(result)
        XCTAssertEqual(result.accessToken, "ACCESS_TOKEN")
        XCTAssertEqual(result.refreshToken, "REFRESH_TOKEN")
        XCTAssertEqual(result.tokenType, UserToken.TokenType.bearer)
    }

}
