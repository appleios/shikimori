//
//  MainViewController.swift
//  Shikimori
//
//  Created by Aziz L on 25.04.2018.
//  Copyright © 2018 Aziz L. All rights reserved.
//

import UIKit


class MainViewController: UIViewController {

    let serviceAccessRequestFactory = ServiceAccessURLRequestFactory()
    let authCodeStorage: AuthCodeStorage = AuthCodeStorage.default

    var httpRequest: HttpRequest<UserToken>?

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self,
                selector: #selector(handleAuthCodeChange),
                name: AuthCodeStorage.AuthCodeDidChangeNotification,
                object: nil)
    }

    @objc func handleAuthCodeChange() {
        let httpRequest: HttpRequest<UserToken> = serviceAccessRequestFactory.getTokenRequest()
        self.httpRequest = httpRequest

        let userTokenP = httpRequest.load()
        userTokenP.then { print($0.accessToken) }
    }
}
