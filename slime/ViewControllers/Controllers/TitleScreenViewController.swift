//
//  ViewController.swift
//  slime
//
//  Created by Gabriel Tan on 13/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

class TitleScreenViewController: ViewController<TitleScreenView> {
    override func configureSubviews() {
        setupButtons()
    }
    
    private func setupButtons() {
        let playButtonController = PrimaryButtonController(using: view.playButton)
            .set(color: .green)
            .set(label: "Play")
        playButtonController.onTap {
            self.context.routeTo(.PlayScreen)
        }
        let settingsButtonController = PrimaryButtonController(using: view.settingsButton)
            .set(color: .blue)
            .set(label: "Settings")
        settingsButtonController.onTap {
            self.context.routeTo(.SettingsScreen)
        }
        let creditsButtonController = PrimaryButtonController(using: view.creditsButton)
            .set(color: .purple)
            .set(label: "Credits")
        creditsButtonController.onTap {
            self.context.routeTo(.CreditsScreen)
        }
        
        remember(playButtonController)
        remember(settingsButtonController)
        remember(creditsButtonController)
    }

}

