//
// Created by Aziz Latipov on 26.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation

struct User {

    let id: Int
    let nickname: String
    let avatar: URL?
    let stats: UserStatistics?

}

struct UserStatistics {
    typealias Statistics = [UserRates.Status: Int]

    let anime: Statistics?
    let manga: Statistics?

}
