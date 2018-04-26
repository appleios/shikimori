//
// Created by Aziz Latipov on 26.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation


class AccountRequestFactory: RequestFactory {

    func getAccount(session: Session) -> HttpRequest<Account> {

        let components = urlBuilder.components(withPath: "/api/users/whoami")
        let request: URLRequest = requestBuilder.request(.GET, url: components.url)

        return HttpRequest(urlRequest: request,
                mapper: AccountMapper(jsonDecoder: jsonDecoder),
                urlSession: urlSession)
    }

}


class AccountMapper: HttpMapper<Account> {

    struct Result: Codable {
        var id: String
        var nickname: String
        var avatar: String
    }

    let jsonDecoder: JSONDecoder

    init(jsonDecoder: JSONDecoder) {
        self.jsonDecoder = jsonDecoder
        super.init()
    }

    override func decode(_ data: Data) throws -> Account {
        let result = try jsonDecoder.decode(Result.self, from: data)
        return Account(id: result.id, nickname: result.nickname, avatar: URL(string: result.avatar))
    }

}
