//
// Created by Aziz Latipov on 26.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation


struct Session {

    let token: SessionToken

}

class SessionProvider {

    static let SessionDidChangeNotification = Notification.Name("sessionDidChange")

    static var `main` =  SessionProvider()

    private var tokenRequest: HttpRequest<SessionToken>?
    private var sessionP: Promise<Session>?

    private (set) var currentSession: Session?

    enum SessionProviderError: Error {
        case AuthorizationRequired
    }

    func getSession() throws -> Promise<Session> {
        if sessionP == nil {
            try fetch()
        }

        let p = Promise<Session>()
        sessionP!.chain(p)
        return p
    }

    func fetch() throws {
        guard let authCode = authCodeStorage.authCode else {
            throw SessionProviderError.AuthorizationRequired
        }

        self.sessionP?.cancel()
        self.tokenRequest?.cancel()

        let tokenRequest = loadToken(authCode: authCode)
        let sessionTokenP = tokenRequest.getPromise()!

        let sessionP = Promise<Session>()
        sessionTokenP.then { sessionP.fulfill(Session(token: $0))  }
        sessionTokenP.error { sessionP.reject($0) }

        sessionP.then { [unowned self] (session: Session) in
            self.currentSession = session
            NotificationCenter.default.post(name: SessionProvider.SessionDidChangeNotification, object: self)
        }

        self.sessionP = sessionP
        self.tokenRequest = tokenRequest
    }

    func loadToken(authCode: String) -> HttpRequest<SessionToken> {
        let request = requestFactory.sessionTokenRequest(authCode: authCode)
        let _ = request.load()
        return request
    }

    let requestFactory: RequestFactory
    let authCodeStorage: AuthCodeStorage

    init(requestFactory: RequestFactory = RequestFactory(), authCodeStorage: AuthCodeStorage = AuthCodeStorage.default) {
        self.requestFactory = requestFactory
        self.authCodeStorage = authCodeStorage

        NotificationCenter.default.addObserver(self,
                selector: #selector(handleAuthCodeChange),
                name: AuthCodeStorage.AuthCodeDidChangeNotification,
                object: nil)
    }

    @objc func handleAuthCodeChange() {
        do {
            try fetch()
        } catch {
        }
    }
}