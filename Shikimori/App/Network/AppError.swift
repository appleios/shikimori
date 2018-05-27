//
// Created by Aziz Latipov on 26.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation

public enum AppError: Error {

    case network(underlyingError: Error)
    case invalidGrant(description: String)
    case invalidToken(description: String)
    case corruptedData(data: Data, description: String)
    case unknown(code: String, description: String)
    case fatal(data: Data?, response: URLResponse?)

}

extension AppError: LocalizedError {

    // incorrectly triggered: there is no way to mark `public` extension conforming to protocol
    // swiftlint:disable:next lower_acl_than_parent
    public var errorDescription: String? {
        switch self {
        case .network(let underlyingError):
            return "Error: [network]: \(underlyingError.localizedDescription)"
        case .invalidGrant(let description):
            return "Error: [invalid grant]: \(description)"
        case .invalidToken(let description):
            return "Error: [invalid token]: \(description)"
        case .corruptedData(let data, let description):
            var details = [String]()
            if let printableData = String(data: data, encoding: .utf8) {
                details.append("data: \(printableData)")
            }
            details.append("description: \(description)")
            return "Error: [corrupted data]: data: \(details.joined(separator: ", "))"
        case .unknown(let code, let description):
            return "Error: [unknown]: code = \(code), description = \(description)"
        case .fatal(let data, let response):
            var details = [String]()
            if let unwrappedData = data,
               let printableData = String(data: unwrappedData, encoding: .utf8)
            {
                details.append("data = \"\(printableData)\"")
            }
            if let r = response {
                details.append("response: \(r.debugDescription)")
            }
            return "Error: [fatal]: \(details.joined(separator: ", "))"

        }
    }

}
