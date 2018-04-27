//
// Created by Aziz L on 26.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation


class RequestBuilder {

    let userAgent: String

    init(userAgent: String) {
        self.userAgent = userAgent
    }

    enum HTTPMethod: String {
        case GET = "GET"
        case POST = "POST"
    }

    func request(_ method: HTTPMethod, url: URL?, accessToken: String? = nil) -> URLRequest {
        var r = URLRequest(url: url!)
        r.httpMethod = method.rawValue
        r.setValue("User-Agent", forHTTPHeaderField: userAgent)
        r.setValue("*/*", forHTTPHeaderField: "Accept") // TODO accept json
        if let accessToken = accessToken {
            r.setValue("Authorization", forHTTPHeaderField: "Bearer \(accessToken)")
        }
        return r
    }
}
