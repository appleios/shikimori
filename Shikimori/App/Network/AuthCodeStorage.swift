//
// Created by Aziz Latipov on 26.04.2018.
// Copyright (c) 2018 shikimori.org. All rights reserved.
//

import Foundation


class AuthCodeStorage {

    static let AuthCodeDidChangeNotification = Notification.Name("authCodeDidChange")

    static var `default` =  AuthCodeStorage()

    static var AuthCode: String? // TODO store on disk

    var authCode: String? {
        set {
            AuthCodeStorage.AuthCode = newValue
            NotificationCenter.default.post(name: AuthCodeStorage.AuthCodeDidChangeNotification, object: self)
        }
        get {
            return AuthCodeStorage.AuthCode
        }
    }

}