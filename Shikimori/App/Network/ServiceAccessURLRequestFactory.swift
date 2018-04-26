//
// Created by Aziz Latipov on 25.04.2018.
// Copyright (c) 2018 shikimori.org. All rights reserved.
//

import Foundation


class ServiceAccessURLRequestFactory: ServiceAccessRequestFactory {

    private let urlBuilder = URLBuilder(host: "shikimori.org")
    private let requestBuilder = RequestBuilder()
    private let authConfigProvider = AuthConfigProvider()

    private var authConfig: AuthConfig {
        return authConfigProvider.config!
    }

    func authRequest() -> URLRequest {
        let url = urlBuilder.url(withPath: "/oauth/authorize", queryItems: [
            URLQueryItem(name: "client_id", value: authConfig.clientID),
            URLQueryItem(name: "redirect_uri", value: authConfig.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
        ])
        return requestBuilder.get(url: url!)
    }

}
