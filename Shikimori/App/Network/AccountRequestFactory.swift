//
// Created by Aziz Latipov on 26.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation

class AccountRequestFactory: EndpointRequestFactory {

    func getAccount(session: Session) -> HttpRequest<Account> {

        let url = urlBuilder.url(withPath: "/api/users/whoami")! // swiftlint:disable:this force_unwrapping
        let request: URLRequest = requestFactory.get(url,
                accessToken: session.token.accessToken)

        return HttpRequest(urlRequest: request,
                mapper: AccountRequestResultMapper(),
                errorMapper: AppErrorMapper(jsonDecoder: jsonDecoder),
                urlSession: urlSession)
    }

}

class AccountRequestResultMapper: DefaultNetworkRequestResultMapper<UserResult, Account> {

    override func convert(_ result: UserResult) throws -> Account {
        let userMapper = UserRequestResultMapper()
        let user: User = try userMapper.convert(result)
        return Account(user: user)
    }

}
