//
//  AnimeEndpointTests.swift
//  Shikimori
//
//  Created by Aziz Latipov on 19.05.2018.
//  Copyright © 2018 Aziz L. All rights reserved.
//

import XCTest
import Foundation
@testable import Shikimori


class AnimeEndpointTests: XCTestCase {

    func testAnimeByID() {
        let data = """
        {
          "id": 3,
          "name": "anime_2",
          "russian": null,
          "image": {
            "original": "/assets/globals/missing_original.jpg",
            "preview": "/assets/globals/missing_preview.jpg",
            "x96": "/assets/globals/missing_x96.jpg",
            "x48": "/assets/globals/missing_x48.jpg"
          },
          "url": "/animes/3-anime-2",
          "kind": "tv",
          "status": null,
          "episodes": 0,
          "episodes_aired": 0,
          "aired_on": null,
          "released_on": null,
          "rating": "pg_13",
          "english": [
            null
          ],
          "japanese": [
            null
          ],
          "synonyms": [],
          "duration": 0,
          "score": "1.0",
          "description": null,
          "description_html": "<p class='b-nothing_here'>Нет описания</p>",
          "description_source": null,
          "franchise": null,
          "favoured": false,
          "anons": null,
          "ongoing": null,
          "thread_id": 212660,
          "topic_id": 212660,
          "myanimelist_id": 3,
          "rates_scores_stats": [],
          "rates_statuses_stats": [],
          "updated_at": "2017-01-10T15:00:00.000+03:00",
          "next_episode_at": null,
          "genres": [],
          "studios": [],
          "videos": [],
          "screenshots": [],
          "user_rate": null
        }
        """.data(using: .utf8)

        let mapper = AnimeRequestResultMapper(baseURL: URL(string: "https://example.com")!)
        let result: Anime = try! mapper.mapToDomain(data!)

        XCTAssertNotNil(result)
        XCTAssertEqual(result.id, 3)
        XCTAssertEqual(result.name, "anime_2")
        XCTAssertEqual(result.russian, nil)
        XCTAssertEqual(result.originalImageURL.absoluteString, "https://example.com/assets/globals/missing_original.jpg")
        XCTAssertEqual(result.previewImageURL.absoluteString, "https://example.com/assets/globals/missing_preview.jpg")
        XCTAssertEqual(result.url.absoluteString, "https://example.com/animes/3-anime-2")

    }

}

