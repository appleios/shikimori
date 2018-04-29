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

    var account: Account!
    var imageLoading: ImageLoading?


    static func viewController(account: Account) -> ProfileViewController {
        let viewController: ProfileViewController =
                UIStoryboard(name: "Profile", bundle: nil).instantiateInitialViewController() as! ProfileViewController

        viewController.account = account
        if let url = account.avatar {
            let imageOperation = ImageDownloadOperation(sourceURL: url, filename: "user-avatar")
            imageOperation.load()
            imageOperation.imageP.then { [weak viewController] (image: UIImage) in
                guard let viewController = viewController else { return }
                viewController.profileImageView.image = image
            }
            viewController.imageLoading = imageOperation
        }


        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.nicknameLabel.text = self.account.nickname
    }
}
