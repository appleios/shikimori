//
// Created by Aziz Latipov on 26.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation


class AccountRequestFactory: EndpointRequestFactory {

    func getAccount(session: Session) -> HttpRequest<Account> {

        let urlBuilder = self.urlBuilder.components(withPath: "/api/users/whoami")
        let request: URLRequest = requestFactory.request(.GET, url: urlBuilder.url, accessToken: session.token.accessToken)

        return HttpRequest(urlRequest: request,
                mapper: AccountRequestResultMapper(),
                errorMapper: AppErrorMapper(jsonDecoder: jsonDecoder),
                urlSession: urlSession)
    }

}


class AccountRequestResultMapper: DefaultNetworkRequestResultMapper<UserResult, Account> {

    init() {
        super.init(converter: ClosureSalToDomainConverter({ (result: UserResult) in
            let userMapper = UserRequestResultMapper()
            let user: User = try! userMapper.convert(result)
            return Account(user: user)
        }))
    }

}
