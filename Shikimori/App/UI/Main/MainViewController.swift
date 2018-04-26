//
//  MainViewController.swift
//  Shikimori
//
//  Created by Aziz L on 25.04.2018.
//  Copyright © 2018 Aziz L. All rights reserved.
//

import UIKit


class MainViewController: UIViewController, AuthViewControllerDelegate {

    let authCodeStorage: AuthCodeStorage = AuthCodeStorage.default
    let sessionProvider = SessionProvider.main

    override func viewDidLoad() {
        super.viewDidLoad()

        getSession()

        NotificationCenter.default.addObserver(self,
                selector: #selector(handleSessionChange),
                name: SessionProvider.SessionDidChangeNotification,
                object: nil)
    }

    private func getSession() {
        do {
            let sessionP = try sessionProvider.getSession()
            sessionP.then { (session: Session) in
                print("session.token = \(session.token)")
            }
        } catch SessionProvider.SessionProviderError.AuthorizationRequired {
            let viewController = AuthViewController.viewController(delegate: self)
            self.present(viewController, animated: true)
        } catch {
            print("Unexpected error while fetching Session: \(error)")
        }
    }

    func authViewController(_ viewController: AuthViewController, didCompleteWithAuthCode authCode: String) {
        authCodeStorage.authCode = authCode
        self.getSession()
        self.dismiss(animated: true)
    }

    @objc func handleSessionChange() {
    }

    @IBAction func openMenu(_ sender: Any) {
        
    }
}
