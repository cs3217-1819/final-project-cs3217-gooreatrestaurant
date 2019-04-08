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
        configureBackButton()
        configureResetButton()
    }

    private func configureBackButton() {
        let control = ButtonController(using: view.backButton)
        control.onTap {
            self.context.routeTo(.TitleScreen)
        }
        remember(control)
    }

    private func configureResetButton() {
        let control = PrimaryButtonController(using: view.resetButton)
            .set(label: "Reset Data")
            .set(color: .purple)
        control.configure()
        control.onTap {
            self.context.data.resetData()
        }
        remember(control)
    }
}
