//
// Created by Aziz Latipov on 26.04.2018.
// Copyright (c) 2018 shikimori.org. All rights reserved.
//

import Foundation


class TokenRequestFactory {

    private let urlBuilder: URLBuilder
    private let requestBuilder: RequestBuilder
    private let session: URLSession
    private var jsonDecoder: JSONDecoder

    init(urlBuilder: URLBuilder, requestBuilder: RequestBuilder, session: URLSession, jsonDecoder: JSONDecoder) {
        self.urlBuilder = urlBuilder
        self.requestBuilder = requestBuilder
        self.session = session
        self.jsonDecoder = jsonDecoder
    }

    func getTokenRequest(authConfig config: AuthConfig, authCode: String) -> HttpRequest<UserToken> {

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
                session: session)
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