//
// Created by Aziz Latipov on 18.05.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation
import UIKit


protocol CellPresenterTableViewSupport {

    var reuseIdentifier: String { get }

    func register(withTableView tableView: UITableView)

    func configureTableViewCell(_ cell: UITableViewCell)
}


protocol CellPresenter {

    var tableViewSupport: CellPresenterTableViewSupport { get }

}
