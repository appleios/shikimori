//
// Created by Aziz Latipov on 26.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation


public enum AppError: Error {

    case network(underlyingError: Error)
    case invalidGrant(description: String)
    case invalidToken(description: String)
    case unknown(code: String, description: String)
    case fatal(data: Data?, response: HTTPURLResponse?)

}

extension AppError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .network(let underlyingError):
            return "Error: [network]: \(underlyingError.localizedDescription)"
        case .invalidGrant(let description):
            return "Error: [invalid grant]: \(description)"
        case .invalidToken(let description):
            return "Error: [invalid token]: \(description)"
        case .unknown(let code, let description):
            return "Error: [unknown]: code = \(code), description = \(description)"
        case .fatal(let data, let response):
            var details = [String]()
            if let d = data {
                details.append("data = \"\(String(data: d, encoding: .utf8)!)\"")
            }
            if let r = response {
                details.append("response: \(r.debugDescription)")
            }
            return "Error: [fatal]: \(details.joined(separator: ", "))"

        }
    }

}
