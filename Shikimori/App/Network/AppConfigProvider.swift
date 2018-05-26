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
        guard let url = Bundle.main.url(forResource: "Auth", withExtension: "plist") else { return nil }
        guard let dict = NSDictionary.init(contentsOf: url) else { return nil }

        let clientID = dict.value(forKey: "client_id") as! String
        let clientSecret = dict.value(forKey: "client_secret") as! String
        let redirectURI = dict.value(forKey: "redirect_uri") as! String
        let appName = dict.value(forKey: "app_name") as! String

        return AppConfig(clientID: clientID,
                clientSecret: clientSecret,
                redirectURI: redirectURI,
                appName: appName)
    }

}
