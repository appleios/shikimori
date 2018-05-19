//
// Created by Aziz L on 25.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation


class EndpointRequestFactory {

    let urlBuilder: URLBuilder
    let requestFactory: RequestFactory
    let urlSession: URLSession
    var jsonDecoder: JSONDecoder

    init(urlBuilder: URLBuilder, requestFactory: RequestFactory, urlSession: URLSession, jsonDecoder: JSONDecoder) {
        self.urlBuilder = urlBuilder
        self.requestFactory = requestFactory
        self.urlSession = urlSession
        self.jsonDecoder = jsonDecoder
    }

}


class ServiceAccessLayer {

    private let urlFactory = URLBuilder(host: "shikimori.org")

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

    func getAuth() -> URLRequest {
        let config = appConfig

        let url = urlFactory.url(withPath: "/oauth/authorize", queryItems: [
            URLQueryItem(name: "client_id", value: config.clientID),
            URLQueryItem(name: "redirect_uri", value: config.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
        ])

        return requestFactory.get(url)
    }

    func getSessionToken(authCode: String) -> HttpRequest<SessionToken> {
        let factory = TokenRequestFactory(urlBuilder: urlFactory,
                requestFactory: requestFactory,
                urlSession: urlSession,
                jsonDecoder: jsonDecoder)

        return factory.getTokenRequest(authConfig: appConfig, authCode: authCode)
    }

    func getSessionRefreshToken(refreshToken: String) -> HttpRequest<SessionToken> {
        let factory = TokenRequestFactory(urlBuilder: urlFactory,
                requestFactory: requestFactory,
                urlSession: urlSession,
                jsonDecoder: jsonDecoder)

        return factory.refreshTokenRequest(authConfig: appConfig, refreshToken: refreshToken)
    }

    func getAccount(session: Session) -> HttpRequest<Account> {
        let factory = AccountRequestFactory(urlBuilder: urlFactory,
                requestFactory: requestFactory,
                urlSession: urlSession,
                jsonDecoder: jsonDecoder)

        return factory.getAccount(session: session)
    }

    func getUser(byID userID: Int, session: Session) -> HttpRequest<User> {
        let factory = UserRequestFactory(urlBuilder: urlFactory,
                requestFactory: requestFactory,
                urlSession: urlSession,
                jsonDecoder: jsonDecoder)

        return factory.getUser(byID: userID, session: session)
    }

    func getUserRates(byID userID: Int,
                      status: UserRates.Status,
                      targetType: UserRates.TargetType,
                      session: Session) -> HttpRequest<[UserRates]>
    {
        let factory = UserRatesRequestFactory(urlBuilder: urlFactory,
                requestFactory: requestFactory,
                urlSession: urlSession,
                jsonDecoder: jsonDecoder)

        return factory.getUserRates(byID: userID,
                status: status,
                targetType: targetType,
                session: session)
    }

}
