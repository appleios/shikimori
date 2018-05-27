//
// Created by Aziz Latipov on 17.05.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation

struct Anime {

    enum Kind: String {
        case tv
    }

    let id: Int
    let name: String
    let russian: String?
    let originalImageURL: URL
    let previewImageURL: URL
    let url: URL
    let kind: Kind
    let status: String?
    let nextEpisodeAt: Date?

}
