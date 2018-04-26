//
// Created by Aziz Latipov on 26.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation


class AccountProvider {

    private (set) static var `main` = AccountProvider()

    private (set) var currentAccount: Account?

    private var request: HttpRequest<Account>?
    private var accountP: Promise<Account>?

    func getAccount(sessionP: Promise<Session>) -> Promise<Account> {
        if accountP == nil {
            fetch(sessionP: sessionP)
        }

        let p = Promise<Account>()
        accountP!.chain(p)
        return p
    }

    private func fetch(sessionP: Promise<Session>) {

        self.accountP?.cancel()
        self.request?.cancel()

        let accountP = Promise<Account>()

        sessionP.then { [unowned self] (session: Session) in
            let accountTokenP = self.loadAccount(session: session)
            accountTokenP.then { accountP.fulfill($0) }
            accountTokenP.error { accountP.reject($0) }
        }

        accountP.then { [unowned self] (account: Account) in
            self.currentAccount = account
        }

        self.accountP = accountP
    }

    private func loadAccount(session: Session) -> Promise<Account> {
        let request = service.accountRequest(session: session)
        self.request = request
        return request.load()
    }

    private let service: ServiceAccessLayer

    init(service: ServiceAccessLayer = ServiceAccessLayer()) {
        self.service = service
    }

}
