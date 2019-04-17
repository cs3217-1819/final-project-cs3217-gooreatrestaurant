//
//  CreditsSceneViewController.swift
//  slime
//
//  Created by Gabriel Tan on 17/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class CreditsSceneViewController: ViewController<CreditsScreenView> {
    required init(with view: UIView) {
        super.init(with: view)
    }

    override func configureSubviews() {
        UIView.animate(withDuration: 1.5, delay: 0, options: [.repeat, .autoreverse], animations: {
            let rot = "\(0.1 * Double.pi)"
            self.view.huiqiView.rotation = rot
            self.view.gabrielView.rotation = rot
            self.view.anthonyView.rotation = rot
            self.view.samuelView.rotation = rot
        }, completion: nil)

        let controller = ButtonController(using: view.backButton)
        controller.sound = "back"
        controller.onTap {
            self.context.routeTo(.TitleScreen)
        }
        remember(controller)
    }
}
