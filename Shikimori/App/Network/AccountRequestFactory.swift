//
// Created by Aziz Latipov on 26.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation


class AccountRequestFactory: EndpointRequestFactory {

    func getAccount(session: Session) -> HttpRequest<Account> {

        let urlBuilder = self.urlBuilder.components(withPath: "/api/users/whoami")
        let request: URLRequest = requestFactory.request(.GET, url: urlBuilder.url, accessToken: session.token.accessToken)

        // DefaultNetworkRequestParser - should obtain this object from single entry among all points
        let mapper = DefaultNetworkRequestParser<UserResult, Account>({ (result: UserResult) in
            let user = User(id: result.id,
                    nickname: result.nickname,
                    avatar: URL(string: result.avatar),
                    stats: nil)

            return Account(user: user)
        })

        return HttpRequest(urlRequest: request,
                mapper: mapper,
                errorMapper: AppErrorMapper(jsonDecoder: jsonDecoder),
                urlSession: urlSession)
    }

}
