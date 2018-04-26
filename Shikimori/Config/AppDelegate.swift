//
//  AppDelegate.swift
//  Shikimori
//
//  Created by Aziz Latipov on 25.04.2018.
//  Copyright © 2018 shikimori.org. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let url = URL(string: "https://shikimori.org/oauth/token")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("shikimory iOS", forHTTPHeaderField: "User-Agent")
        return true
    }

}
