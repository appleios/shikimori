//
// Created by Aziz L on 26.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation

class URLBuilder {

    func url(withPath path: String, queryItems: [URLQueryItem] = []) -> URL? {
        var comp: URLComponents = components(withPath: path)
        comp.queryItems = queryItems
        return comp.url
    }

    func components(withPath path: String) -> URLComponents {
        var components: URLComponents = createComponents()
        components.path = path
        return components
    }

    private let host: String
    private let scheme: String

    init(host: String, scheme: String = "https") {
        self.host = host
        self.scheme = scheme
    }

    private func createComponents() -> URLComponents {
        var components = URLComponents()
        components.host = host
        components.scheme = scheme
        return components
    }
}
