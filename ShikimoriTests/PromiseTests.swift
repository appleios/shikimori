//
// Created by Aziz Latipov on 26.04.2018.
// Copyright (c) 2018 shikimori.org. All rights reserved.
//

import Foundation


import XCTest
@testable import Shikimori


class PromiseTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    struct TestError: Error {
    }

    func testIsPendingOnCreate() {
        let p = Promise<Int>()

        XCTAssertTrue(p.isPending())
    }

    func testThen() {
        let p = Promise<Int>()
        var test = 0
        p.then { test = $0 }
        p.fulfill(10)

        XCTAssertEqual(test, 10)
    }

    func testError() {
        let p = Promise<Int>()
        var test: Error?
        p.error { test = $0 }
        p.reject(TestError())

        XCTAssertNotNil(test)
    }

    func testCompletion() {
        let p = Promise<Int>()
        let q = Promise<Int>()
        var testP = 0
        var testQ: Error?

        p.then { testP = $0 }
        q.error { testQ = $0 }

        p.fulfill(20)
        q.reject(TestError())

        XCTAssertEqual(testP, 20)
        XCTAssertNotNil(testQ)
    }

    func testChain() {
        let q = Promise<Int>()
        let p = Promise<Int>()
        var test = 0

        q.then { test = $0 }
        p.chain(q)

        p.fulfill(30)

        XCTAssertEqual(test, 30)
    }

    // TODO test thread safety
}
