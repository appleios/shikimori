//
// Created by Aziz Latipov on 26.04.2018.
// Copyright (c) 2018 shikimori.org. All rights reserved.
//

import Foundation


class RequestBuilder {

    private enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }

    func get(url: URL?) -> URLRequest {
        return request(method: .get, url: url)
    }

    func post(url: URL?) -> URLRequest {
        return request(method: .post, url: url)
    }

    private func request(method: HTTPMethod, url: URL?) -> URLRequest {
        var request = URLRequest(url: url!)
        request.httpMethod = method.rawValue
        return request
    }

}
