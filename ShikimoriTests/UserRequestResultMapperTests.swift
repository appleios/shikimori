//
// Created by Aziz Latipov on 17.05.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation
@testable import Shikimori
import XCTest

class UserRequestResultMapperTests: XCTestCase {

    let avatar = "https://host.com/avatar"
    let animePlanned = 1
    let animeWatching = 2
    let animeDropped = 3
    let animeCompleted = 4
    let animeOnHold = 5
    let mangaWatching = 6

    // swiftlint:disable line_length
    // swiftlint:disable:next function_body_length
    func fixture() -> String {
        return """
        {
          "id": 12345,
          "nickname": "NICKNAME",
          "avatar": \"https://host.com/avatar\",
          "image": {
            "x160": "http:///assets/globals/missing_avatar/x160.png",
            "x148": "http:///assets/globals/missing_avatar/x148.png",
            "x80": "http:///assets/globals/missing_avatar/x80.png",
            "x64": "http:///assets/globals/missing_avatar/x64.png",
            "x48": "http:///assets/globals/missing_avatar/x48.png",
            "x32": "http:///assets/globals/missing_avatar/x32.png",
            "x16": "http:///assets/globals/missing_avatar/x16.png"
          },
          "last_online_at": "2017-01-10T15:00:00.000+03:00",
          "name": null,
          "sex": null,
          "full_years": null,
          "last_online": "сейчас на сайте",
          "website": "",
          "location": null,
          "banned": false,
          "about": null,
          "about_html": "",
          "common_info": [
            "Нет личных данных",
            "на сайте с <span class='b-unprocessed mobile' data-direction='right' title='10 января 2017 г.'>10 января 2017 г.</span>"
          ],
          "show_comments": false,
          "in_friends": null,
          "is_ignored": false,
          "stats": {
            "statuses": {
              "anime": [
                {
                  "id": 0,
                  "name": "planned",
                  "size": \(animePlanned),
                  "grouped_id": "planned",
                  "type": "Anime"
                },
                {
                  "id": 1,
                  "name": "watching",
                  "size": \(animeWatching),
                  "grouped_id": "watching,rewatching",
                  "type": "Anime"
                },
                {
                  "id": 2,
                  "name": "completed",
                  "size": \(animeCompleted),
                  "grouped_id": "completed",
                  "type": "Anime"
                },
                {
                  "id": 3,
                  "name": "on_hold",
                  "size": \(animeOnHold),
                  "grouped_id": "on_hold",
                  "type": "Anime"
                },
                {
                  "id": 4,
                  "name": "dropped",
                  "size": \(animeDropped),
                  "grouped_id": "dropped",
                  "type": "Anime"
                }
              ],
              "manga": [
                {
                  "id": 0,
                  "name": "planned",
                  "size": 0,
                  "grouped_id": "planned",
                  "type": "Manga"
                },
                {
                  "id": 1,
                  "name": "watching",
                  "size": \(mangaWatching),
                  "grouped_id": "watching,rewatching",
                  "type": "Manga"
                },
                {
                  "id": 2,
                  "name": "completed",
                  "size": 0,
                  "grouped_id": "completed",
                  "type": "Manga"
                },
                {
                  "id": 3,
                  "name": "on_hold",
                  "size": 0,
                  "grouped_id": "on_hold",
                  "type": "Manga"
                },
                {
                  "id": 4,
                  "name": "dropped",
                  "size": 0,
                  "grouped_id": "dropped",
                  "type": "Manga"
                }
              ]
            },
            "full_statuses": {
              "anime": [
                {
                  "id": 0,
                  "name": "planned",
                  "size": 0,
                  "grouped_id": "planned",
                  "type": "Anime"
                },
                {
                  "id": 1,
                  "name": "watching",
                  "size": 0,
                  "grouped_id": "watching",
                  "type": "Anime"
                },
                {
                  "id": 9,
                  "name": "rewatching",
                  "size": 0,
                  "grouped_id": "rewatching",
                  "type": "Anime"
                },
                {
                  "id": 2,
                  "name": "completed",
                  "size": 0,
                  "grouped_id": "completed",
                  "type": "Anime"
                },
                {
                  "id": 3,
                  "name": "on_hold",
                  "size": 0,
                  "grouped_id": "on_hold",
                  "type": "Anime"
                },
                {
                  "id": 4,
                  "name": "dropped",
                  "size": 0,
                  "grouped_id": "dropped",
                  "type": "Anime"
                }
              ],
              "manga": [
                {
                  "id": 0,
                  "name": "planned",
                  "size": 0,
                  "grouped_id": "planned",
                  "type": "Manga"
                },
                {
                  "id": 1,
                  "name": "watching",
                  "size": 0,
                  "grouped_id": "watching",
                  "type": "Manga"
                },
                {
                  "id": 9,
                  "name": "rewatching",
                  "size": 0,
                  "grouped_id": "rewatching",
                  "type": "Manga"
                },
                {
                  "id": 2,
                  "name": "completed",
                  "size": 0,
                  "grouped_id": "completed",
                  "type": "Manga"
                },
                {
                  "id": 3,
                  "name": "on_hold",
                  "size": 0,
                  "grouped_id": "on_hold",
                  "type": "Manga"
                },
                {
                  "id": 4,
                  "name": "dropped",
                  "size": 0,
                  "grouped_id": "dropped",
                  "type": "Manga"
                }
              ]
            },
            "scores": {
              "anime": [],
              "manga": []
            },
            "types": {
              "anime": [],
              "manga": []
            },
            "ratings": {
              "anime": []
            },
            "has_anime?": false,
            "has_manga?": false,
            "genres": [],
            "studios": [],
            "publishers": [],
            "activity": {}
          },
          "style_id": null
        }
        """
    }
    // swiftlint:enable line_length

    func testUserById() {
        guard let data = fixture().data(using: .utf8) else {
            XCTFail("Incorrect fixture")
            return
        }

        var result: User
        do {
            let mapper = UserRequestResultMapper()
            result = try mapper.mapToDomain(data)
        } catch {
            XCTFail("Mapping result is nil")
            return
        }

        XCTAssertEqual(result.id, 12_345)
        XCTAssertEqual(result.nickname, "NICKNAME")
        XCTAssertEqual(result.avatar, URL(string: "https://host.com/avatar"))

        XCTAssertNotNil(result.stats)
        XCTAssertNotNil(result.stats?.anime)

        // swiftlint:disable:next force_unwrapping
        let anime = result.stats!.anime!

        XCTAssertEqual(anime[UserRates.Status.planned], animePlanned)
        XCTAssertEqual(anime[UserRates.Status.dropped], animeDropped)
        XCTAssertEqual(anime[UserRates.Status.watching], animeWatching)
        XCTAssertEqual(anime[UserRates.Status.onHold], animeOnHold)
        XCTAssertEqual(anime[UserRates.Status.completed], animeCompleted)

        XCTAssertNotNil(result.stats?.manga)

        // swiftlint:disable:next force_unwrapping
        let manga = result.stats!.manga!

        XCTAssertEqual(manga[UserRates.Status.watching], mangaWatching)
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
        do {
            let mapper = AccountRequestResultMapper()
            result = try mapper.mapToDomain(data)
        } catch {
            XCTFail("Mapping result is nil")
            return
        }

        XCTAssertEqual(result.user.id, 12_345)
    }

}
