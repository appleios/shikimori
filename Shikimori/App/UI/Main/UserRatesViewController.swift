//
//  UserRatesViewController.swift
//  Shikimori
//
//  Created by Aziz Latipov on 18.05.2018.
//  Copyright © 2018 Aziz L. All rights reserved.
//

import Foundation
import UIKit


class UserRatesViewController: UITableViewController {

    var userRatesP: Promise<[UserRates]>?

    override func viewDidLoad() {
        userRatesP?.then { [weak self] _ in
            self?.tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let userRatesP = self.userRatesP, let userRates = userRatesP.value else {
            return 0
        }

        return userRates.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userRates = self.userRatesP!.value!
        let rate = userRates[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.textLabel?.text = "\(rate.targetId)"

        return cell
    }

}
