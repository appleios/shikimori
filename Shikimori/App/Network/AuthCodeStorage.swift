//
// Created by Aziz L on 26.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation


class AuthCodeStorage {

    static let AuthCodeDidChangeNotification = Notification.Name("authCodeDidChange")

    private (set) static var `default` =  AuthCodeStorage()

    var authCode: String? {
        set {
            userDefaults.set(newValue, forKey: key)
            userDefaults.synchronize()
            NotificationCenter.default.post(name: AuthCodeStorage.AuthCodeDidChangeNotification, object: self)
        }
        get {
            return userDefaults.string(forKey: key)
        }
    }

    private let key = "AuthCode"
    private var userDefaults: UserDefaults {
        return UserDefaults.standard
    }

}