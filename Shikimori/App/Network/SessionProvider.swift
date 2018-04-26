//
// Created by Aziz Latipov on 26.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation


struct Session: Codable {

    let token: SessionToken

}

class SessionProvider {

    static let SessionDidChangeNotification = Notification.Name("sessionDidChange")

    private (set) static var `main` = SessionProvider()

    private var request: HttpRequest<SessionToken>?
    private var sessionP: Promise<Session>? {
        didSet {
            if let p = sessionP {
                p.then { [unowned self] (session: Session) in
                    self.currentSession = session
                }
            }
        }
    }

    enum SessionProviderError: Error {
        case AuthorizationRequired
    }

    func getSession() throws -> Promise<Session> {
        if self.sessionP == nil {
            try fetch()
        } else {
            let sessionP = self.sessionP!
            if sessionP.isFulfilled() {
                let session = sessionP.value()!
                if session.token.expired() {
                    refresh(expiredSession: session)
                }
            } else if sessionP.isError() {
                try fetch()
            }
        }

        // TODO suggest better chaining API
        let p = Promise<Session>()
        self.sessionP!.chain(p)
        return p
    }

    private func fetch() throws {
        guard let authCode = authCodeStorage.authCode else {
            throw SessionProviderError.AuthorizationRequired
        }

        self.sessionP?.cancel()
        self.request?.cancel()

        let sessionTokenP = loadToken(authCode: authCode)
        self.setupSessionP(withSessionTokenP: sessionTokenP)
    }

    private func refresh(expiredSession session: Session) {
        self.sessionP?.cancel()
        self.request?.cancel()

        let sessionTokenP = refreshToken(refreshToken: session.token.refreshToken)
        self.setupSessionP(withSessionTokenP: sessionTokenP)
    }

    private func setupSessionP(withSessionTokenP sessionTokenP: Promise<SessionToken>) {
        let sessionP = Promise<Session>()
        sessionTokenP.then { sessionP.fulfill(Session(token: $0))  }
        sessionTokenP.error { sessionP.reject($0) }

        self.sessionP = sessionP
    }

    private func loadToken(authCode: String) -> Promise<SessionToken> {
        let request = service.sessionTokenRequest(authCode: authCode)
        self.request = request
        return request.load()
    }

    private func refreshToken(refreshToken: String) -> Promise<SessionToken> {
        let request = service.sessionRefreshTokenRequest(refreshToken: refreshToken)
        self.request = request
        return request.load()
    }

    private let service: ServiceAccessLayer
    private let authCodeStorage: AuthCodeStorage

    private let persistentStorage: KeyValuePersistentStorage<Session>

    init(service: ServiceAccessLayer = ServiceAccessLayer(), authCodeStorage: AuthCodeStorage = AuthCodeStorage.default) {
        self.service = service
        self.authCodeStorage = authCodeStorage
        self.persistentStorage = KeyValuePersistentStorage<Session>.archiverStorage(withKey: "Session")
        self.currentSession = persistentStorage.value

        NotificationCenter.default.addObserver(self,
                selector: #selector(handleAuthCodeChange),
                name: AuthCodeStorage.AuthCodeDidChangeNotification,
                object: nil)
    }

    private (set) var currentSession: Session? {
        didSet {
            if let session = currentSession {
                persistentStorage.value = session
            }
            NotificationCenter.default.post(name: SessionProvider.SessionDidChangeNotification, object: self)
        }
    }

    @objc func handleAuthCodeChange() {
        do {
            try fetch()
        } catch {
        }
    }
}
