//
//  SessionProviderTests.swift
//  Shikimori
//
//  Created by Aziz Latipov on 27.04.2018.
//  Copyright © 2018 Aziz L. All rights reserved.
//

import XCTest
import Foundation
@testable import Shikimori


class SessionProviderTests: XCTestCase {

    func testSessionProviderFetchStrategy() {
        let sessionProvider: SessionProvider = SessionProvider() // TODO use proper init()

        let sessionP = Promise<Session>()
        let currentSession = Session(token: SessionToken(accessToken: "",
                refreshToken: "",
                createdAt: Date(),
                expireDate: Date() + TimeInterval(1),
                tokenType: .bearer))

        let strategy: SessionProvider.SessionProviderFetchStrategy =
                sessionProvider.fetchStrategy(forSessionP: sessionP, currentSession: currentSession)


    }

}
