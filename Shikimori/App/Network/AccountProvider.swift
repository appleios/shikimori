//
// Created by Aziz Latipov on 26.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation


struct Account {

    let user: User

}


class AccountProvider {

    private (set) static var `main` = AccountProvider()

    private (set) var currentAccount: Account?

    private var request: HttpRequest<Account>?
    private var accountP: Promise<Account>?

    func getAccount(sessionP: Promise<Session>) -> Promise<Account> {
        if accountP == nil {
            fetch(sessionP: sessionP)
        }

        return accountP!.chained
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
        let request = service.getAccount(session: session)
        self.request = request
        return try! request.load()
    }

    private let service: ServiceAccessLayer

    init(service: ServiceAccessLayer = ServiceAccessLayer()) {
        self.service = service
    }

}
