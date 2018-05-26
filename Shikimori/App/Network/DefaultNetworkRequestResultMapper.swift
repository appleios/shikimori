//
// Created by Aziz L on 26.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation

/// Decoder takes data, i.e. JSON, and creates **SAL Type** (Service Access Level Type).
/// For example the `User` JSON
/// ```
/// {
///   "id": 100,
///   "name": "John"
/// }
/// ```
///  is transformed into struct:
/// ```
/// struct UserResult: Codable {
///     var id: Int
///     var name: String
/// }
/// ```
class NetworkDataDecoder<SalType> {

    func decode(_ data: Data) throws -> SalType {
        fatalError("not implemented")
    }

}

/// Mapper takes decoded object, i.g. `UserResult` from example above and creates **Domain Type**:
/// ```
/// struct User {
///     let id: Int
///     let firstName: String
///     let lastName: String
/// }
/// ```
class SalToDomainConverter<SalType, DomainType> {

    func convert(_ result: SalType) throws -> DomainType {
        fatalError("not implemented")
    }

}

class DefaultNetworkRequestResultMapper<SalType, DomainType>: NetworkRequestResultMapper<DomainType>
        where SalType: Decodable {

    class JsonResultDecoder: NetworkDataDecoder<SalType> {

        // TODO get JSONDecoder from single entry among all points
        static var defaultJSONDecoder: JSONDecoder {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return decoder
        }

        var jsonDecoder: JSONDecoder

        init(jsonDecoder: JSONDecoder = defaultJSONDecoder) {
            self.jsonDecoder = jsonDecoder
        }

        override func decode(_ data: Data) throws -> SalType {
            return try jsonDecoder.decode(SalType.self, from: data)
        }

    }

    typealias Mapping = (_ result: SalType) throws -> DomainType
    internal class ClosureSalToDomainConverter: SalToDomainConverter<SalType, DomainType> {

        var mapping: Mapping

        init(_ mapping: @escaping Mapping) {
            self.mapping = mapping
        }

        override func convert(_ result: SalType) throws -> DomainType {
            return try self.mapping(result)
        }

    }

    let decoder: NetworkDataDecoder<SalType>
    let converter: SalToDomainConverter<SalType, DomainType>

    init(converter: SalToDomainConverter<SalType, DomainType>,
         decoder: NetworkDataDecoder<SalType> = JsonResultDecoder()) {
        self.decoder = decoder
        self.converter = converter
    }

    override func mapToDomain(_ data: Data) throws -> DomainType {
        return try convert(try decode(data))
    }

    internal func decode(_ data: Data) throws -> SalType {
        return try decoder.decode(data)
    }

    internal func convert(_ result: SalType) throws -> DomainType {
        return try converter.convert(result)
    }

}
