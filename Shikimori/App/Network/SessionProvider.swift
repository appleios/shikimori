//
// Created by Aziz Latipov on 26.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation


struct Session: Codable, Equatable {

    let token: SessionToken

    static func ==(lhs: Session, rhs: Session) -> Bool {
        return lhs.token == rhs.token
    }
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

    enum SessionProviderError: Error, Equatable {
        case AuthorizationRequired

        static func ==(lhs: SessionProviderError, rhs: SessionProviderError) -> Bool {
            switch (lhs, rhs) {
            case (.AuthorizationRequired, .AuthorizationRequired):
                return true
            }
        }
    }

    enum SessionProviderFetchStrategy: Equatable {
        case Refresh(previousSession: Session)
        case Fetch
        case Nothing
        case Fail(error: SessionProviderError)

        static func ==(lhs: SessionProviderFetchStrategy, rhs: SessionProviderFetchStrategy) -> Bool {
            switch (lhs, rhs) {
            case (.Refresh(let s1), .Refresh(let s2)):
                return s1 == s2

            case (.Fetch, .Fetch):
                return true

            case (.Nothing, .Nothing):
                return true

            case (.Fail(let e1), .Fail(let e2)):
                return e1 == e2

            default:
                return false
            }
        }
    }

    func getSession() throws -> Promise<Session> {
        let strategy: SessionProviderFetchStrategy =
                self.fetchStrategy(forSessionP: self.sessionP, currentSession: self.currentSession)

        switch strategy {
        case .Refresh(let previousSession):
            refresh(expiredSession: previousSession)
            break

        case .Fetch:
            try self.fetch()
            break

        case .Nothing:
            break

        case .Fail(let error):
            throw error
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

    internal func fetchStrategy(forSessionP sessionP: Promise<Session>?, currentSession: Session?) -> SessionProviderFetchStrategy {
        return FetchStrategyCalculator().fetchStrategy(forSessionP: sessionP, currentSession: currentSession)
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

    struct FetchStrategyCalculator {

        func fetchStrategy(forSessionP sessionP: Promise<Session>?, currentSession: Session?) -> SessionProviderFetchStrategy {
            if sessionP == nil {
                return refreshStrategyOrNil(forSession: currentSession) ?? SessionProviderFetchStrategy.Fetch
            }
            return strategy(forUnwrapped: sessionP!, currentSession: currentSession) ?? SessionProviderFetchStrategy.Fetch
        }

        private func strategy(forUnwrapped sessionP: Promise<Session>, currentSession session: Session?) -> SessionProviderFetchStrategy? {

            switch sessionP.state {
            case .fulfilled(let session):
                return refreshStrategyOrNil(forSession: session) ?? SessionProviderFetchStrategy.Nothing

            case .error(let error):
                if let error = error {
                    return strategy(forError: error, session: session) ?? SessionProviderFetchStrategy.Fetch
                } else {
                    return refreshStrategyOrNil(forSession: session) ?? SessionProviderFetchStrategy.Fetch
                }

            case .pending:
                return SessionProviderFetchStrategy.Nothing
            }
        }

        private func strategy(forError error: Error, session: Session?) -> SessionProviderFetchStrategy? {
            guard let error = error as? AppError else {
                return nil
            }

            switch error {
            case .invalidToken:
                if session != nil {
                    return SessionProviderFetchStrategy.Refresh(previousSession: session!)
                }
            case .invalidGrant:
                return SessionProviderFetchStrategy.Fail(error: .AuthorizationRequired)
            default: // TODO handle other error types (!)
                break
            }
            return nil
        }

        private func refreshStrategyOrNil(forSession session: Session?) -> SessionProviderFetchStrategy? {
            if session != nil && session!.token.isExpired(){
                return SessionProviderFetchStrategy.Refresh(previousSession: session!)
            }
            return nil
        }

    }
}
