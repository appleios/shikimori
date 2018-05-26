//
// Created by Aziz Latipov on 27.05.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation
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

}
