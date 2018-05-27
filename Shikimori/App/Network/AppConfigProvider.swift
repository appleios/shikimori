//
// Created by Aziz L on 25.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation

struct AppConfig {
    let clientID: String
    let clientSecret: String
    let redirectURI: String
    let appName: String
}

class AppConfigProvider {

    var config: AppConfig? {
        guard let url = Bundle.main.url(forResource: "Auth", withExtension: "plist") else {
            return nil
        }
        guard let dict = NSDictionary.init(contentsOf: url) else {
            return nil
        }

        guard let clientID = dict.value(forKey: "client_id") as? String else {
            fatalError("Incorrect type for client_id in Auth.plist")
        }
        guard let clientSecret = dict.value(forKey: "client_secret") as? String else {
            fatalError("Incorrect type for client_secret in Auth.plist")
        }
        guard let redirectURI = dict.value(forKey: "redirect_uri") as? String else {
            fatalError("Incorrect type for redirect_uri in Auth.plist")
        }
        guard let appName = dict.value(forKey: "app_name") as? String else {
            fatalError("Incorrect type for app_name in Auth.plist")
        }

        return AppConfig(clientID: clientID,
                clientSecret: clientSecret,
                redirectURI: redirectURI,
                appName: appName)
    }

}
