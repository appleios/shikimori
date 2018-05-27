//
// Created by Aziz L on 25.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    let accountProvider = AccountProvider.main
    lazy var authHelper: AuthHelper = {
        return AuthHelper(viewController: self)
    }()

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
            if let error = error {
                print("Unexpected error while fetching Session: \(error)")
            }
        }

        let accountP = self.accountProvider.getAccount(sessionP: sessionP)
        accountP.then { [weak self] (account: Account) in
            guard let sSelf = self else {
                return
            }

            DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 1000)) {
                guard let session: Session = sessionP.value else {
                    return
                }

                let viewController = ProfileViewController.viewController(account: account, session: session)

                // swiftlint:disable:next force_unwrapping
                sSelf.navigationController!.show(viewController, sender: nil)
            }
        }
        accountP.error { error in
            if let error = error {
                print("Unexpected error while fetching Account: \(error.localizedDescription)")
            }
        }
    }

    @objc
    func handleSessionChange() {

    }

    @IBAction private func openMenu(_ sender: Any) {

    }
}
