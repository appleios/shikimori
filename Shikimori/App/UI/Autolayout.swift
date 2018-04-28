//
// Created by Aziz Latipov on 28.04.2018.
// Copyright (c) 2018 Aziz L. All rights reserved.
//

import Foundation
import UIKit


extension UIView {

    func autoPinToSuperviewEdges() {
        let container = self.superview!
        self.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
        self.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
    }

}
