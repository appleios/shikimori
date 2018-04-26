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
    private var sessionP: Promise<Session>?

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

    private func fetch() throws {
        guard let authCode = authCodeStorage.authCode else {
            throw SessionProviderError.AuthorizationRequired
        }

        self.sessionP?.cancel()
        self.request?.cancel()

        let sessionTokenP = loadToken(authCode: authCode)

        let sessionP = Promise<Session>()
        sessionTokenP.then { sessionP.fulfill(Session(token: $0))  }
        sessionTokenP.error { sessionP.reject($0) }

        sessionP.then { [unowned self] (session: Session) in
            self.currentSession = session
        }

        self.sessionP = sessionP
    }

    private func loadToken(authCode: String) -> Promise<SessionToken> {
        let request = service.sessionTokenRequest(authCode: authCode)
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