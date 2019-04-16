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
        let control = PrimaryButtonController(usingXib: view.resetButton)
            .set(label: "Reset Data")
            .set(color: .purple)
        control.sound = "back"
        control.configure()
        control.onTap {
            self.showConfirmResetDialog()
        }
        remember(control)
    }
    
    private func showConfirmResetDialog() {
        let alert = context.modal.createAlert()
            .setTitle("Confirm Reset?")
            .setDescription("Are you sure you want to reset all data? This cannot be undone.")
            .addAction(AlertAction(with: "Reset", callback: {
                self.context.data.resetData()
                self.context.routeTo(.TitleScreen)
            }, of: .Danger))
            .addAction(AlertAction(with: "Cancel"))
        context.modal.presentAlert(alert)
    }
}
