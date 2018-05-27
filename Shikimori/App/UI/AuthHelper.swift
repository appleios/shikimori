//
// Created by Aziz Latipov on 26.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation
import UIKit

// TODO [smell] core logic located in Helper object
class AuthHelper: AuthViewControllerDelegate {

    let authCodeStorage: AuthCodeStorage = AuthCodeStorage.default
    let sessionProvider = SessionProvider.main

    let viewController: UIViewController

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    private var sessionP: Promise<Session>!

    func getSession() -> Promise<Session> {
        let sessionP = Promise<Session>()
        self.sessionP = sessionP

        fulfill(sessionP: sessionP)

        return sessionP.chained
    }

    private func fulfill(sessionP: Promise<Session>) {
        do {
            let p = try sessionProvider.getSession()
            p.then { sessionP.fulfill($0) }
            p.error { [weak self] (error: Error?) in
                guard let sSelf = self else {
                    return
                }

                if let appError = error as? AppError {
                    switch appError {
                    case .invalidGrant:
                        sSelf.presentAuthViewController()
                    default:
                        print("Unexpected error: \(appError)")
                    }
                }
                sSelf.presentAuthViewController()
            }
        } catch SessionProvider.SessionProviderError.authorizationRequired {
            presentAuthViewController()
        } catch {
            sessionP.reject(error)
        }
    }

    private func presentAuthViewController() {
        let authViewController = AuthViewController.viewController(delegate: self)
        self.viewController.present(authViewController, animated: true)
    }

    internal func authViewController(_ viewController: AuthViewController, didCompleteWithAuthCode authCode: String) {
        authCodeStorage.authCode = authCode
        self.fulfill(sessionP: self.sessionP)
        self.viewController.dismiss(animated: true)
    }

}
