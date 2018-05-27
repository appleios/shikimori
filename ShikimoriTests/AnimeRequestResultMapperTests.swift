//
// Created by Aziz Latipov on 19.05.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation
@testable import Shikimori
import XCTest

class AnimeRequestResultMapperTests: BaseMappingTests {

    func testAnimeByID() {
        let data = fixture(file: "AnimeRequestResultMapperFixture")

        let dateFormatter = AnimeRequestResultMapper.dateFormatterForISO8601()
        let date = dateFormatter.date(from: "2018-05-25T15:00:00.000+03:00")
        XCTAssertNotNil(date)

        // swiftlint:disable:next force_unwrapping
        let baseURL = URL(string: "https://example.com")!
        let mapper = AnimeRequestResultMapper(baseURL: baseURL)

        let result: Anime = tryMapping(mapper, data: data)

        XCTAssertEqual(result.id, 36_296)
        XCTAssertEqual(result.name, "Hinamatsuri")
        XCTAssertEqual(result.russian, "Праздник кукол")
        XCTAssertEqual(result.originalImageURL.absoluteString, "https://example.com/system/original/36296.jpg")
        XCTAssertEqual(result.previewImageURL.absoluteString, "https://example.com/system/preview/36296.jpg")
        XCTAssertEqual(result.url.absoluteString, "https://example.com/animes/36296-hinamatsuri")
        XCTAssertNotNil(result.nextEpisodeAt)

    }

}
