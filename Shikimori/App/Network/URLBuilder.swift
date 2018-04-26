//
// Created by Aziz Latipov on 26.04.2018.
// Copyright (c) 2018 shikimori.org. All rights reserved.
//

import Foundation


class URLBuilder {

    func url(withPath path: String, queryItems: [URLQueryItem]?) -> URL? {
        var components: URLComponents = createComponents()
        components.path = path
        components.queryItems = queryItems
        return components.url
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
