//
// Created by Aziz Latipov on 25.04.2018.
// Copyright (c) 2018 shikimori.org. All rights reserved.
//

import Foundation


class ServiceAccessURLRequestFactory {

    private let urlBuilder = URLBuilder(host: "shikimori.org")
    private let requestBuilder = RequestBuilder(userAgent: "shikimori iOS")
    private let authConfigProvider = AuthConfigProvider()

    private let authCodeStorage: AuthCodeStorage = AuthCodeStorage.default

    private var authConfig: AuthConfig {
        return authConfigProvider.config!
    }

    var jsonDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
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
        let factory = TokenRequestFactory(urlBuilder: urlBuilder,
                requestBuilder: requestBuilder,
                session: session,
                jsonDecoder: jsonDecoder)

        let authCode = authCodeStorage.authCode!
        return factory.getTokenRequest(authConfig: authConfig, authCode: authCode)
    }

}
