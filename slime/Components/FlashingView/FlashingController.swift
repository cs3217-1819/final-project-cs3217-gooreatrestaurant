//
//  FlashingController.swift
//  slime
//
//  Created by Gabriel Tan on 12/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class FlashingController: Controller {
    let view: UIView
    var duration: TimeInterval = 0.5
    
    init(with view: UIView) {
        self.view = view
    }
    
    func configure() {
        UIView.animate(withDuration: duration, delay: 0.0, options: [.repeat, .autoreverse], animations: {
            self.view.alpha = 0.05
        }, completion: nil)
    }
}
