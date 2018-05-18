//
// Created by Aziz L on 26.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation


struct UserTokenResult: Codable {
    var accessToken: String
    var refreshToken: String
    var createdAt: Date
    var expiresIn: Int
    var tokenType: String
}


class TokenRequestFactory: EndpointRequestFactory {

    func getTokenRequest(authConfig config: AppConfig, authCode: String) -> HttpRequest<SessionToken> {
        return self.requestWithForm(form: [
            "grant_type": "authorization_code",
            "code": authCode,
            "client_id": config.clientID,
            "client_secret": config.clientSecret,
            "redirect_uri": config.redirectURI,
        ])
    }

    func refreshTokenRequest(authConfig config: AppConfig, refreshToken: String) -> HttpRequest<SessionToken> {
        return self.requestWithForm(form: [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken,
            "client_id": config.clientID,
            "client_secret": config.clientSecret,
            "redirect_uri": config.redirectURI,
        ])
    }

    private func requestWithForm(form: [String:String]) -> HttpRequest<SessionToken> {
        let components = urlBuilder.components(withPath: "/oauth/token")
        var request: URLRequest = requestFactory.request(.POST, url: components.url)

        let boundary = "BOUNDARY"
        let formEncoder = FormEncoder(boundary: boundary)
        let body = formEncoder.encode(form: form)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = body.data(using: .utf8)

        return HttpRequest(urlRequest: request,
                mapper: TokenRequestResultMapper(),
                errorMapper: AppErrorMapper(jsonDecoder: jsonDecoder),
                urlSession: urlSession)
    }

    internal struct FormEncoder {

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

class TokenRequestResultMapper: DefaultNetworkRequestResultMapper<UserTokenResult, SessionToken> {

    init() {
        super.init(converter: ClosureSalToDomainConverter({ (result: UserTokenResult) in
            return SessionToken(accessToken: result.accessToken,
                    refreshToken: result.refreshToken,
                    createdAt: result.createdAt,
                    expireDate: result.createdAt + TimeInterval(result.expiresIn),
                    tokenType: SessionToken.TokenType(rawValue: result.tokenType)!)
        }))
    }
}
