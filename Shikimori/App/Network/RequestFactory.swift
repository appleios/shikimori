//
// Created by Aziz L on 25.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation


class RequestFactory {

    private let urlBuilder = URLBuilder(host: "shikimori.org")
    private let requestBuilder = RequestBuilder(userAgent: "shikimori iOS")
    private let appConfigProvider = AppConfigProvider()

    private var appConfig: AppConfig {
        return appConfigProvider.config!
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
        let config = appConfig

        var components = urlBuilder.components(withPath: "/oauth/authorize")
        components.queryItems = [
            URLQueryItem(name: "client_id", value: config.clientID),
            URLQueryItem(name: "redirect_uri", value: config.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
        ]

        return requestBuilder.get(url: components.url!)
    }


    func sessionTokenRequest(authCode: String) -> HttpRequest<SessionToken> {
        let factory = TokenRequestFactory(urlBuilder: urlBuilder,
                requestBuilder: requestBuilder,
                session: session,
                jsonDecoder: jsonDecoder)

        return factory.getTokenRequest(authConfig: appConfig, authCode: authCode)
    }

}
