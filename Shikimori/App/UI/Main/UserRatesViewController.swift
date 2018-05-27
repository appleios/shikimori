//
// Created by Aziz Latipov on 18.05.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation
import UIKit

class UserRatesViewController: UITableViewController {

    var userRatesP: Promise<[UserRates]>?
    var session: Session!

    var sal = ServiceAccessLayer()
    var animesP: [Int: Promise<Anime>] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

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
        // swiftlint:disable:next force_unwrapping
        let userRates = userRatesP!.value!
        let rate: UserRates = userRates[indexPath.row]

        // swiftlint:disable:next force_unwrapping
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.textLabel?.text = "\(rate.targetId)"

        var animeP = animesP[indexPath.row]
        if animeP == nil {
            let request = sal.getAnime(byID: rate.targetId, session: session)

            let loadP = request.load()
            loadP.then { [weak self] _ in
                self?.tableView.reloadData()
            }

            animeP = loadP
            animesP[indexPath.row] = loadP
        }
        if let animeP = animeP {
            if animeP.isFulfilled() {
                if let anime: Anime = animeP.value {
                    cell.textLabel?.text = anime.name
                }
            }
        }

        return cell
    }

}
