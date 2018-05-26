//
//  UsersEndpointTests.swift
//  Shikimori
//
//  Created by Aziz Latipov on 17.05.2018.
//  Copyright © 2018 Aziz L. All rights reserved.
//

import XCTest
import Foundation
@testable import Shikimori

class UserRequestTests: XCTestCase {

    func testUserById() {
        let avatar = "https://host.com/avatar"
        let anime_planned = 1
        let anime_watching = 2
        let anime_dropped = 3
        let anime_completed = 4
        let anime_on_hold = 5
        let manga_watching = 6
        let data = """
        {
          "id": 12345,
          "nickname": "NICKNAME",
          "avatar": \"\(avatar)\",
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
                  "size": \(anime_planned),
                  "grouped_id": "planned",
                  "type": "Anime"
                },
                {
                  "id": 1,
                  "name": "watching",
                  "size": \(anime_watching),
                  "grouped_id": "watching,rewatching",
                  "type": "Anime"
                },
                {
                  "id": 2,
                  "name": "completed",
                  "size": \(anime_completed),
                  "grouped_id": "completed",
                  "type": "Anime"
                },
                {
                  "id": 3,
                  "name": "on_hold",
                  "size": \(anime_on_hold),
                  "grouped_id": "on_hold",
                  "type": "Anime"
                },
                {
                  "id": 4,
                  "name": "dropped",
                  "size": \(anime_dropped),
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
                  "size": \(manga_watching),
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
        """.data(using: .utf8)

        let mapper = UserRequestResultMapper()
        let result: User = try! mapper.mapToDomain(data!)

        XCTAssertNotNil(result)
        XCTAssertEqual(result.id, 12345)
        XCTAssertEqual(result.nickname, "NICKNAME")
        XCTAssertEqual(result.avatar, URL(string: avatar))

        let anime = result.stats!.anime!
        XCTAssertEqual(anime[UserRates.Status.planned], anime_planned)
        XCTAssertEqual(anime[UserRates.Status.dropped], anime_dropped)
        XCTAssertEqual(anime[UserRates.Status.watching], anime_watching)
        XCTAssertEqual(anime[UserRates.Status.onHold], anime_on_hold)
        XCTAssertEqual(anime[UserRates.Status.completed], anime_completed)

        let manga = result.stats!.manga!
        XCTAssertEqual(manga[UserRates.Status.watching], manga_watching)
    }

}
