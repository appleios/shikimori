//
// Created by Aziz Latipov on 19.05.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation

struct UserRates {

    enum Status: String {
        case planned
        case watching
        case rewatching
        case completed
        case onHold = "on_hold"
        case dropped
    }

    enum TargetType: String {
        case anime = "Anime"
        case manga = "Manga"
    }

    let targetId: Int
    let targetType: TargetType

}
