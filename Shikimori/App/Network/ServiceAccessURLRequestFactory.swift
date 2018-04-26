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

    private var jsonDecoder: JSONDecoder {
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

        let config = authConfig
        let authCode = authCodeStorage.authCode!

        let components = urlBuilder.components(withPath: "/oauth/token")
        var request: URLRequest = requestBuilder.post(url: components.url)

        let boundary = "BOUNDARY"
        let formEncoder = FormEncoder(boundary: boundary)
        let body = formEncoder.encode(form: [
            "grant_type": "authorization_code",
            "client_id": config.clientID,
            "client_secret": config.clientSecret,
            "code": authCode,
            "redirect_uri": config.redirectURI,
        ])
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = body.data(using: .utf8)

        return HttpRequest(urlRequest: request,
                mapper: UserTokenMapper(decoder: jsonDecoder),
                session: self.session)
    }

    struct FormEncoder {

        let boundary: String

        func encode(form: [String:String]) -> String {
            var body = ""
            for (key, value) in form {
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.append("\(value)\r\n")
            }
            body.append("--\(boundary)--\r\n")
            return body
        }
    }

}
