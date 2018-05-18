//
//  ProfileViewController.swift
//  Shikimori
//
//  Created by Aziz Latipov on 28.04.2018.
//  Copyright © 2018 Aziz L. All rights reserved.
//

import UIKit


class ProfileViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!

    var session: Session!
    var account: Account!
    var imageLoading: ImageLoading?
    let sal = ServiceAccessLayer()

    static func viewController(account: Account, session: Session) -> ProfileViewController {
        let viewController: ProfileViewController =
                UIStoryboard(name: "Profile", bundle: nil).instantiateInitialViewController() as! ProfileViewController

        viewController.account = account
        viewController.session = session

        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.nicknameLabel.text = self.account.user.nickname

        if let url = account.user.avatar {
            let imageOperation = ImageDownloadOperation(sourceURL: url, filename: "user-avatar")
            imageOperation.load()
            imageOperation.imageP.then { [weak profileImageView] (image: UIImage) in
                profileImageView?.image = image
            }
            self.imageLoading = imageOperation
        }


        let userP = sal.getUser(byID: self.account.user.id, session: self.session)
        do {
            try userP.load().then { print($0.stats) }
        } catch {
            print("unexpected error: \(error)")
        }

    }
}
