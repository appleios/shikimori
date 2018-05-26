//
//  MenuViewController.swift
//  Shikimori
//
//  Created by Aziz Latipov on 26.04.2018.
//  Copyright © 2018 Aziz L. All rights reserved.
//

import UIKit

protocol MenuViewControllerDelegate: class {

    func menuViewControllerOpenProfile(viewController: MenuViewController)

}

class MenuViewController: UITableViewController {

    weak var delegate: MenuViewControllerDelegate?

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.menuViewControllerOpenProfile(viewController: self)
    }

}
