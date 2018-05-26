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

    let sessionProvider: SessionProvider = SessionProvider() // TODO use proper init()

    // - fetchStrategy has 2 arguments with variations:
    //
    // * sessionP ->
    // 1. nil
    // 2. cancelled
    // 3. pending
    // 4. fulfilled(valid)
    // 5. fulfilled(expired)
    // 6. error (invalidToken/invalidGrant) // TODO handle other error types
    //
    // * currentSession ->
    // 1. nil
    // 2. valid
    // 3. expired
    //
    // which gives 7 * 3 = 21 combinations
    //
    func testNil() {
        assertInvalidSessionP(withSessionP: nil)
    }

    func testCancelled() {
        let cancelledP = Promise<Session>()
        cancelledP.cancel()

        assertInvalidSessionP(withSessionP: cancelledP)
    }

    func testPending() {
        let pending = Promise<Session>()

        assertNoRespectCurrent(withSessionP: pending,
                expectedResult: .nothing)
    }

    func testFulfilledValid() {
        let fulfilled = Promise<Session>(withValue: createValidSession())

        assertNoRespectCurrent(withSessionP: fulfilled,
                expectedResult: .nothing)
    }

    func testFulfilledExpired() {
        let session = createExpiredSession()
        let fulfilled = Promise<Session>(withValue: session)

        assertNoRespectCurrent(withSessionP: fulfilled,
                expectedResult: .refresh(previousSession: session))
    }

    func testErrorInvalidToken() {
        let error = AppError.invalidToken(description: "")
        let sessionP = Promise<Session>(withError: error)

        assert(withSessionP: sessionP,
                currentSession: nil,
                expectedResult: .fetch)

        let validSession = createValidSession()
        assert(withSessionP: sessionP,
                currentSession: validSession,
                expectedResult: .refresh(previousSession: validSession))

        let expiredSession = createExpiredSession()
        assert(withSessionP: sessionP,
                currentSession: expiredSession,
                expectedResult: .refresh(previousSession: expiredSession))
    }

    func testErrorInvalidGrant() {
        let error = AppError.invalidGrant(description: "")
        let sessionP = Promise<Session>(withError: error)

        assertNoRespectCurrent(withSessionP: sessionP,
                expectedResult: .fail(error: SessionProvider.SessionProviderError.authorizationRequired))
    }

    // MARK: -

    private func assertInvalidSessionP(withSessionP invalidSessionP: Promise<Session>?) {
        assert(withSessionP: invalidSessionP,
                currentSession: nil,
                expectedResult: .fetch)

        assert(withSessionP: invalidSessionP,
                currentSession: createValidSession(),
                expectedResult: .fetch)

        let session = createExpiredSession()
        assert(withSessionP: invalidSessionP,
                currentSession: session,
                expectedResult: .refresh(previousSession: session))
    }

    private func assertNoRespectCurrent(withSessionP sessionP: Promise<Session>,
                                        expectedResult: SessionProvider.SessionProviderFetchStrategy) {
        assert(withSessionP: sessionP,
                currentSession: nil,
                expectedResult: expectedResult)

        assert(withSessionP: sessionP,
                currentSession: createValidSession(),
                expectedResult: expectedResult)

        assert(withSessionP: sessionP,
                currentSession: createExpiredSession(),
                expectedResult: expectedResult)
    }

    private func assert(withSessionP sessionP: Promise<Session>?,
                        currentSession session: Session?,
                        expectedResult: SessionProvider.SessionProviderFetchStrategy) {
        let strategy: SessionProvider.SessionProviderFetchStrategy =
                sessionProvider.fetchStrategy(forSessionP: sessionP, currentSession: session)

        XCTAssertEqual(strategy, expectedResult)
    }

    // MARK: -

    func createValidSession() -> Session {
        let createdAt = Date()

        return createSession(withCreatedAt: createdAt,
                expireDate: createdAt + TimeInterval(1))
    }

    func createExpiredSession() -> Session {
        let createdAt = Date()

        return createSession(withCreatedAt: createdAt,
                expireDate: createdAt - TimeInterval(1))
    }

    func createSession(withCreatedAt createdAt: Date, expireDate: Date) -> Session {
        return Session(token: SessionToken(accessToken: "",
                refreshToken: "",
                createdAt: createdAt,
                expireDate: expireDate,
                tokenType: .bearer))
    }

}
