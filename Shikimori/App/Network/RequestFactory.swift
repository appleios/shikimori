//
// Created by Aziz L on 26.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation


class RequestFactory {

    let userAgent: String

    init(userAgent: String) {
        self.userAgent = userAgent
    }

    enum HTTPMethod: String {
        case GET = "GET"
        case POST = "POST"
    }

    func get(_ url: URL?, accessToken: String? = nil) -> URLRequest {
        return request(.GET, url: url, accessToken: accessToken)
    }

    func post(_ url: URL?, accessToken: String? = nil) -> URLRequest {
        return request(.POST, url: url, accessToken: accessToken)
    }

    func request(_ method: HTTPMethod, url: URL?, accessToken: String? = nil) -> URLRequest {
        var r = URLRequest(url: url!)
        r.httpMethod = method.rawValue
        r.setValue("User-Agent", forHTTPHeaderField: userAgent)
        r.setValue("*/*", forHTTPHeaderField: "Accept") // TODO accept json
        if let accessToken = accessToken {
            r.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        return r
    }

}
