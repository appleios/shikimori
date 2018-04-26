//
// Created by Aziz Latipov on 25.04.2018.
// Copyright (c) 2018 shikimori.org. All rights reserved.
//

import Foundation


class ServiceAccessURLRequestFactory {

    private let urlBuilder = URLBuilder(host: "shikimori.org")
    private let requestBuilder = RequestBuilder(userAgent: "shikimori iOS")
    private let authConfigProvider = AuthConfigProvider()

    private let authCodeStorage: AuthCodeStorage = AuthCodeStorage()

    private var authConfig: AuthConfig {
        return authConfigProvider.config!
    }

    let session: URLSession

    init() {
        self.session = URLSession(configuration: URLSessionConfiguration.default)
    }

    func authRequest() -> URLRequest {
        let config = authConfig

        var components = urlBuilder.components(withPath: "/oauth/authorize")
        components.queryItems = [
            URLQueryItem(name: "client_id", value: config.clientID),
            URLQueryItem(name: "redirect_uri", value: config.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
        ]

        return requestBuilder.get(url: components.url!)
    }

    func getTokenRequest() -> HttpRequest<UserToken> {
        let config = authConfig
        let authCode = authCodeStorage.authCode

        let components = urlBuilder.components(withPath: "/oauth/token")
        var request: URLRequest = requestBuilder.post(url: components.url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let body = [
            "grant_type=\("authorization_code")",
            "client_id=\(config.clientID)",
            "client_secret=\(config.clientSecret)",
            "redirect_uri=\(config.redirectURI)",
            "code=\(authCode)"
        ]
        request.httpBody = Data(base64Encoded: body.joined(separator: "&"))

        return HttpRequest(urlRequest: request, session: self.session)
    }

}
