//
//  SettingsScreenViewController.swift
//  slime
//
//  Created by Gabriel Tan on 18/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class SettingsScreenViewController: ViewController<SettingsScreenView> {
    override func configureSubviews() {
        let control = ButtonController(using: view.backButton)
        control.onTap {
            self.router.routeTo(.TitleScreen)
        }
        remember(control)
    }
}
