//
//  UserRatesEndpointTests.swift
//  Shikimori
//
//  Created by Aziz Latipov on 18.05.2018.
//  Copyright © 2018 Aziz L. All rights reserved.
//

import XCTest
import Foundation
@testable import Shikimori

class UserRatesEndpointTests: XCTestCase {

    func testUserRates() {
        let data = """
        [
          {
            "id": 15,
            "user_id": 23456853,
            "target_id": 45,
            "target_type": "Anime",
            "score": 0,
            "status": "planned",
            "rewatches": 0,
            "episodes": 0,
            "volumes": 0,
            "chapters": 0,
            "text": null,
            "text_html": null,
            "created_at": "2017-01-10T15:00:00.000+03:00",
            "updated_at": "2017-01-10T15:00:00.000+03:00"
          },
          {
            "id": 16,
            "user_id": 23456853,
            "target_id": 46,
            "target_type": "Manga",
            "score": 0,
            "status": "planned",
            "rewatches": 0,
            "episodes": 0,
            "volumes": 0,
            "chapters": 0,
            "text": null,
            "text_html": null,
            "created_at": "2017-01-10T15:00:00.000+03:00",
            "updated_at": "2017-01-10T15:00:00.000+03:00"
          }
        ]
        """.data(using: .utf8)

        let mapper = UserRatesRequestResultMapper()
        let result: [UserRates] = try! mapper.mapToDomain(data!)

        XCTAssertNotNil(result)
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].targetType, UserRates.TargetType.anime)
        XCTAssertEqual(result[0].targetId, 45)
        XCTAssertEqual(result[1].targetType, UserRates.TargetType.manga)
        XCTAssertEqual(result[1].targetId, 46)
    }

}
