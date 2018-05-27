//
// Created by Aziz Latipov on 27.05.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation
@testable import Shikimori
import XCTest

class BaseMappingTests: XCTestCase {

    func fixture(file: String, extension ext: String = "json") -> Data {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: file, withExtension: ext) else {
            fatalError("Fixture file \(file) does not exist")
        }
        do {
            return try Data(contentsOf: url)
        } catch {
            fatalError("Failed to read Fixture file")
        }
    }

    func fixture(body: String) -> Data {
        guard let data = body.data(using: .utf8) else {
            fatalError("Incorrect fixture")
        }
        return data
    }

    func tryMapping<T>(_ mapper: NetworkRequestResultMapper<T>, data: Data) -> T {
        var tryResult: T?
        do {
            tryResult = try mapper.mapToDomain(data)
        } catch {
            fatalError("Failed to decode")
        }

        guard let result = tryResult else {
            fatalError("Mapping result is nil")
        }
        return result
    }

}
