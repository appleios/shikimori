//
// Created by Aziz Latipov on 17.05.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation
@testable import Shikimori
import XCTest

class UserRequestResultMapperTests: BaseMappingTests {

    func testUserById() {
        let data = fixture(file: "UserRequestResultMapperFixture")

        let result: User = tryMapping(UserRequestResultMapper(), data: data)

        XCTAssertEqual(result.id, 12_345)
        XCTAssertEqual(result.nickname, "NICKNAME")
        XCTAssertEqual(result.avatar, URL(string: "https://host.com/avatar"))

        XCTAssertNotNil(result.stats)
        XCTAssertNotNil(result.stats?.anime)

        // swiftlint:disable:next force_unwrapping
        let anime = result.stats!.anime!

        XCTAssertEqual(anime[UserRates.Status.planned], 1)
        XCTAssertEqual(anime[UserRates.Status.dropped], 5)
        XCTAssertEqual(anime[UserRates.Status.watching], 2)
        XCTAssertEqual(anime[UserRates.Status.onHold], 4)
        XCTAssertEqual(anime[UserRates.Status.completed], 3)

        XCTAssertNotNil(result.stats?.manga)

        // swiftlint:disable:next force_unwrapping
        let manga = result.stats!.manga!

        XCTAssertEqual(manga[UserRates.Status.watching], 6)
    }

    func testWhoami() {
        let data = fixture(body: """
        {
            "id": 12345,
            "nickname": "NICKNAME",
            "avatar": null
        }
        """)

        let result: Account = tryMapping(AccountRequestResultMapper(), data: data)

        XCTAssertEqual(result.user.id, 12_345)
    }

}
