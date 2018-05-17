//
// Created by Aziz L on 25.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation


class EndpointRequestFactory {

    let urlFactory: URLFactory
    let requestFactory: RequestFactory
    let urlSession: URLSession
    var jsonDecoder: JSONDecoder

    init(urlFactory: URLFactory, requestFactory: RequestFactory, urlSession: URLSession, jsonDecoder: JSONDecoder) {
        self.urlFactory = urlFactory
        self.requestFactory = requestFactory
        self.urlSession = urlSession
        self.jsonDecoder = jsonDecoder
    }

}


class ServiceAccessLayer {

    private let urlFactory = URLFactory(host: "shikimori.org")

    private let appConfigProvider: AppConfigProvider
    private let appConfig: AppConfig

    private let requestFactory: RequestFactory
    private let urlSession: URLSession

    var jsonDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    init(appConfigProvider: AppConfigProvider = AppConfigProvider()) {
        self.appConfigProvider = appConfigProvider
        self.appConfig = appConfigProvider.config!
        self.requestFactory = RequestFactory(userAgent: appConfig.appName)
        self.urlSession = URLSession(configuration: URLSessionConfiguration.default)
    }

    func authRequest() -> URLRequest {
        let config = appConfig

        var components = urlFactory.components(withPath: "/oauth/authorize")
        components.queryItems = [
            URLQueryItem(name: "client_id", value: config.clientID),
            URLQueryItem(name: "redirect_uri", value: config.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
        ]

        return requestFactory.request(.GET, url: components.url!)
    }

    func sessionTokenRequest(authCode: String) -> HttpRequest<SessionToken> {
        let factory = TokenRequestFactory(urlFactory: urlFactory,
                requestFactory: requestFactory,
                urlSession: urlSession,
                jsonDecoder: jsonDecoder)

        return factory.getTokenRequest(authConfig: appConfig, authCode: authCode)
    }

    func sessionRefreshTokenRequest(refreshToken: String) -> HttpRequest<SessionToken> {
        let factory = TokenRequestFactory(urlFactory: urlFactory,
                requestFactory: requestFactory,
                urlSession: urlSession,
                jsonDecoder: jsonDecoder)

        return factory.refreshTokenRequest(authConfig: appConfig, refreshToken: refreshToken)
    }

    func accountRequest(session: Session) -> HttpRequest<Account> {
        let factory = AccountRequestFactory(urlFactory: urlFactory,
                requestFactory: requestFactory,
                urlSession: urlSession,
                jsonDecoder: jsonDecoder)

        return factory.getAccount(session: session)
    }

    func userRequest(session: Session, userID: Int) -> HttpRequest<User> {
        let factory = UserRequestFactory(urlFactory: urlFactory,
                requestFactory: requestFactory,
                urlSession: urlSession,
                jsonDecoder: jsonDecoder)

        return factory.getUser(session: session, userID: userID)
    }

}
