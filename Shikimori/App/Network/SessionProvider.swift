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
        case authorizationRequired

        static func ==(lhs: SessionProviderError, rhs: SessionProviderError) -> Bool {
            switch (lhs, rhs) {
            case (.authorizationRequired, .authorizationRequired):
                return true
            }
        }
    }

    enum SessionProviderFetchStrategy: Equatable {
        case refresh(previousSession: Session)
        case fetch
        case nothing
        case fail(error: SessionProviderError)

        static func ==(lhs: SessionProviderFetchStrategy, rhs: SessionProviderFetchStrategy) -> Bool {
            switch (lhs, rhs) {
            case (.refresh(let s1), .refresh(let s2)):
                return s1 == s2

            case (.fetch, .fetch):
                return true

            case (.nothing, .nothing):
                return true

            case (.fail(let e1), .fail(let e2)):
                return e1 == e2

            default:
                return false
            }
        }
    }

    func getSession() throws -> Promise<Session> {
        let strategy: SessionProviderFetchStrategy =
                fetchStrategy(forSessionP: sessionP, currentSession: currentSession)

        switch strategy {
        case .refresh(let previousSession):
            refresh(expiredSession: previousSession)

        case .fetch:
            try fetch()

        case .nothing:
            break

        case .fail(let error):
            throw error
        }

        // swiftlint:disable:next force_unwrapping
        return sessionP!.chained
    }

    private func fetch() throws {
        guard let authCode = authCodeStorage.authCode else {
            throw SessionProviderError.authorizationRequired
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
        let request = service.getSessionToken(authCode: authCode)
        self.request = request
        return request.load()
    }

    private func refreshToken(refreshToken: String) -> Promise<SessionToken> {
        let request = service.getSessionRefreshToken(refreshToken: refreshToken)
        self.request = request
        return request.load()
    }

    internal func fetchStrategy(forSessionP sessionP: Promise<Session>?,
                                currentSession: Session?) -> SessionProviderFetchStrategy
    {
        return FetchStrategyCalculator().fetchStrategy(forSessionP: sessionP, currentSession: currentSession)
    }

    private let service: ServiceAccessLayer
    private let authCodeStorage: AuthCodeStorage

    private let persistentStorage: KeyValuePersistentStorage<Session>

    init(service: ServiceAccessLayer = ServiceAccessLayer(),
         authCodeStorage: AuthCodeStorage = AuthCodeStorage.default)
    {
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

    @objc
    func handleAuthCodeChange() {
        do {
            try fetch()
        } catch {
            fatalError("unexpected case")
        }
    }

    struct FetchStrategyCalculator {

        func fetchStrategy(forSessionP sessionP: Promise<Session>?,
                           currentSession: Session?) -> SessionProviderFetchStrategy
        {
            if sessionP == nil {
                return refreshStrategyOrNil(forSession: currentSession) ?? SessionProviderFetchStrategy.fetch
            }

            // swiftlint:disable:next force_unwrapping
            if let strategy = strategy(forUnwrapped: sessionP!, currentSession: currentSession) {
                return strategy
            }

            return SessionProviderFetchStrategy.fetch
        }

        private func strategy(forUnwrapped sessionP: Promise<Session>,
                              currentSession session: Session?) -> SessionProviderFetchStrategy?
        {
            switch sessionP.state {
            case .fulfilled(let session):
                return refreshStrategyOrNil(forSession: session) ?? SessionProviderFetchStrategy.nothing

            case .error(let error):
                if let error = error {
                    return strategy(forError: error, session: session) ?? SessionProviderFetchStrategy.fetch
                } else {
                    return refreshStrategyOrNil(forSession: session) ?? SessionProviderFetchStrategy.fetch
                }

            case .pending:
                return SessionProviderFetchStrategy.nothing
            }
        }

        private func strategy(forError error: Error, session: Session?) -> SessionProviderFetchStrategy? {
            guard let error = error as? AppError else {
                return nil
            }

            switch error {
            case .invalidToken:
                if let session = session {
                    return SessionProviderFetchStrategy.refresh(previousSession: session)
                }
            case .invalidGrant:
                return SessionProviderFetchStrategy.fail(error: .authorizationRequired)

            default:
                fatalError("unexpected error")
            }
            return nil
        }

        private func refreshStrategyOrNil(forSession session: Session?) -> SessionProviderFetchStrategy? {
            if let session = session, session.token.isExpired() {
                return SessionProviderFetchStrategy.refresh(previousSession: session)
            }
            return nil
        }

    }
}
