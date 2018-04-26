//
// Created by Aziz Latipov on 26.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation
import UIKit


class AuthHelper: AuthViewControllerDelegate {

    let authCodeStorage: AuthCodeStorage = AuthCodeStorage.default
    let sessionProvider = SessionProvider.main

    let viewController: UIViewController

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    private var sessionP: Promise<Session>?

    func getSession() -> Promise<Session> {
        let sessionP = Promise<Session>()
        self.sessionP = sessionP

        fulfill(sessionP: sessionP)

        let result = Promise<Session>() // TODO come up with better API for chaining
        sessionP.chain(result)
        return result
    }

    private func fulfill(sessionP: Promise<Session>) {
        do {
            let p = try sessionProvider.getSession()
            p.chain(sessionP)
        } catch SessionProvider.SessionProviderError.AuthorizationRequired {
            let authViewController = AuthViewController.viewController(delegate: self)
            self.viewController.present(authViewController, animated: true)
        } catch {
            sessionP.reject(error)
        }
    }

    func authViewController(_ viewController: AuthViewController, didCompleteWithAuthCode authCode: String) {
        authCodeStorage.authCode = authCode
        self.fulfill(sessionP: self.sessionP!)
        self.viewController.dismiss(animated: true)
    }

}