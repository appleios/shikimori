//
//  MainViewController.swift
//  Shikimori
//
//  Created by Aziz L on 25.04.2018.
//  Copyright © 2018 Aziz L. All rights reserved.
//

import UIKit


class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let sessionP: Promise<Session> = self.authHelper.getSession()
        sessionP.then { (session: Session) in
            print("session.token = \(session.token)")
        }
        sessionP.error { error in
            print("Unexpected error while fetching Session: \(error)")
        }

        NotificationCenter.default.addObserver(self,
                selector: #selector(handleSessionChange),
                name: SessionProvider.SessionDidChangeNotification,
                object: nil)
    }


    @objc func handleSessionChange() {
    }

    @IBAction func openMenu(_ sender: Any) {
        
    }

    lazy var authHelper: AuthHelper = {
        return AuthHelper(viewController: self)
    }()
}
