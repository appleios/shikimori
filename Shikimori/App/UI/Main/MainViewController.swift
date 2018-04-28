//
//  MainViewController.swift
//  Shikimori
//
//  Created by Aziz L on 25.04.2018.
//  Copyright © 2018 Aziz L. All rights reserved.
//

import UIKit


class MainViewController: UIViewController {

    let accountProvider = AccountProvider.main

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self,
                selector: #selector(handleSessionChange),
                name: SessionProvider.SessionDidChangeNotification,
                object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let sessionP: Promise<Session> = self.authHelper.getSession()
        sessionP.then { (session: Session) in
            print("session.token = \(session.token)")
        }
        sessionP.error { error in
            print("Unexpected error while fetching Session: \(error)")
        }

        let accountP = self.accountProvider.getAccount(sessionP: sessionP)
        accountP.then { (account: Account) in
            let viewController = ProfileViewController.viewController(account: account)
            self.navigationController!.show(viewController, sender: nil)
        }
        accountP.error { error in
            print("Unexpected error while fetching Account: \(error.localizedDescription)")
        }
    }

    @objc func handleSessionChange() {
    }

    @IBAction func openMenu(_ sender: Any) {
        
    }

    lazy var authHelper: AuthHelper = {
        return AuthHelper(viewController: self)
    }()
}
