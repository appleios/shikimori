//
// Created by Aziz L on 26.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
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

    struct TestError: Error, Equatable {
        static func ==(lhs: TestError, rhs: TestError) -> Bool {
            return true
        }
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

    func textDoubleFulfillDontChangeValue() {
        let p = Promise<Int>()
        p.fulfill(10)
        p.fulfill(20)

        XCTAssertEqual(p.value(), 10)
    }

    func textFulfillAndRejectDontChangeValue() {
        let p = Promise<Int>()
        p.fulfill(10)
        p.reject(TestError())

        XCTAssertEqual(p.value(), 10)
        XCTAssertNil(p.error())
    }

    func textRejectAndFulfillDontChangeValue() {
        let error: PromiseTests.TestError = TestError()

        let p = Promise<Int>()
        p.fulfill(10)
        p.reject(error)

        XCTAssertEqual(p.error() as! TestError, error)
        XCTAssertNil(p.value())
    }

    // TODO test thread safety
}
