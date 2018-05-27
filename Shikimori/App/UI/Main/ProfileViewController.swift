//
// Created by Aziz Latipov on 28.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import UIKit

class ProfileImageTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!

}

class ProfileStatisticTableViewCell: UITableViewCell {
}

struct ProfileHeaderCellPresenter: CellPresenter, CellPresenterTableViewSupport {

    let avatar: ImageLoading?
    let nickname: String?

    var tableViewSupport: CellPresenterTableViewSupport {
        return self
    }

    var reuseIdentifier: String {
        return "Header"

    }

    func register(withTableView tableView: UITableView) {
        // already registered in storyboard
    }

    func configureTableViewCell(_ cell: UITableViewCell) {
        guard let headerCell = cell as? ProfileImageTableViewCell else {
            return
        }

        headerCell.avatarImageView.image = avatar?.image
        headerCell.nicknameLabel.text = nickname
    }

}

struct ProfileStatisticCellPresenter: CellPresenter, CellPresenterTableViewSupport {

    let name: String
    let value: Int
    let status: UserRates.Status

    init(name: String, statistics: UserStatistics.Statistics, status: UserRates.Status) {
        self.name = name
        self.status = status

        // swiftlint:disable:next force_unwrapping
        self.value = statistics[status]!
    }

    var tableViewSupport: CellPresenterTableViewSupport {
        return self
    }

    var reuseIdentifier: String {
        return "Statistic"

    }

    func register(withTableView tableView: UITableView) {
        // already registered in storyboard
    }

    func configureTableViewCell(_ cell: UITableViewCell) {
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = "\(value)"
    }

}

class ProfileViewController: UITableViewController {

    static let toUserRatesSegueIdentifier = "To User Rates"

    var session: Session!
    var account: Account!

    var sal = ServiceAccessLayer()
    var userP: Promise<User>?

    var presenters: [CellPresenter] = []

    static func viewController(account: Account, session: Session) -> ProfileViewController {
        guard let viewController: ProfileViewController =
                UIStoryboard(name: "Profile", bundle: nil).instantiateInitialViewController() as? ProfileViewController
        else {
            fatalError("Profile.storyboard initial view controller is of incorrect type")
        }

        viewController.account = account
        viewController.session = session

        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.reloadDataIfNeeded()

        let userRequest = sal.getUser(byID: self.account.user.id, session: self.session)
        let userP: Promise<User> = userRequest.load()
        self.userP = userP
        userP.then { [weak self] _ in
            DispatchQueue.main.async {
                self?.reloadDataIfNeeded()
            }
        }
    }

    private func buildPresenters() -> [CellPresenter] {

        let headerCellPresenter = ProfileHeaderCellPresenter(avatar: avatar,
                nickname: self.account.user.nickname)

        var cellPresenters: [CellPresenter] = [
            headerCellPresenter,
        ]

        if let userP = self.userP, userP.isFulfilled() {

            let user = userP.value! // swiftlint:disable:this force_unwrapping

            if let stats = user.stats {
                if let anime = stats.anime {
                    cellPresenters.append(ProfileStatisticCellPresenter(
                            name: NSLocalizedString("Watching", comment: ""),
                            statistics: anime,
                            status: UserRates.Status.watching))

                    cellPresenters.append(ProfileStatisticCellPresenter(
                            name: NSLocalizedString("Completed", comment: ""),
                            statistics: anime,
                            status: UserRates.Status.completed))

                    cellPresenters.append(ProfileStatisticCellPresenter(
                            name: NSLocalizedString("Dropped", comment: ""),
                            statistics: anime,
                            status: UserRates.Status.dropped))
                }
            }
        }

        return cellPresenters
    }

    func reloadDataIfNeeded() {

        guard isViewLoaded else {
            return
        }

        self.presenters = buildPresenters()
        self.tableView.reloadData()
    }

    // MARK: - TableView DataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenters.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let presenter = presenters[indexPath.row]

        // swiftlint:disable:next force_unwrapping
        let cell = tableView.dequeueReusableCell(withIdentifier: presenter.tableViewSupport.reuseIdentifier)!
        presenter.tableViewSupport.configureTableViewCell(cell)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let presenter = presenters[indexPath.row]
        if presenter is ProfileStatisticCellPresenter {
            self.performSegue(withIdentifier: ProfileViewController.toUserRatesSegueIdentifier, sender: presenter)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ProfileViewController.toUserRatesSegueIdentifier {
            guard let presenter = sender as? ProfileStatisticCellPresenter,
                  let viewController = segue.destination as? UserRatesViewController
            else {
                fatalError("unable to cast")
            }

            let request: HttpRequest<[UserRates]> = sal.getUserRates(byID: account.user.id,
                                                                           status: presenter.status,
                                                                           targetType: .anime,
                                                                           session: session)

            viewController.userRatesP = request.load()
            viewController.session = session
        }
    }

    // MARK: -

    private var avatar: ImageLoading? {
        guard let url = account.user.avatar else {
            return nil
        }

        let imageOperation = ImageDownloadOperation(sourceURL: url, filename: "user-avatar")
        imageOperation.load()
        return imageOperation
    }

}
