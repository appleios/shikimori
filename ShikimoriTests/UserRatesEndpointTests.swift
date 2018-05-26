//
// Created by Aziz Latipov on 18.05.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation
@testable import Shikimori
import XCTest

class UserRatesEndpointTests: BaseMappingTests {

    func testUserRates() {
        let data = fixture(file: "UserRatesEndpointFixture")

        var result: [UserRates]
        do {
            let mapper = UserRatesRequestResultMapper()
            result = try mapper.mapToDomain(data)
        } catch {
            XCTFail("Mapping result is nil")
            return
        }

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].targetType, UserRates.TargetType.anime)
        XCTAssertEqual(result[0].targetId, 45)
        XCTAssertEqual(result[1].targetType, UserRates.TargetType.manga)
        XCTAssertEqual(result[1].targetId, 46)
    }

}
