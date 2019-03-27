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
        setupAnonymousAuth()
    }
    
    private func setupButtons() {
        let playButtonController = PrimaryButtonController(using: view.playButton)
        playButtonController.configure()
        _ = playButtonController
            .set(color: .green)
            .set(label: "Play")
        playButtonController.onTap {
            self.context.routeTo(.PlayScreen)
        }
        let settingsButtonController = PrimaryButtonController(using: view.settingsButton)
        settingsButtonController.configure()
        _ = settingsButtonController
            .set(color: .blue)
            .set(label: "Settings")
        settingsButtonController.onTap {
            self.context.routeTo(.SettingsScreen)
        }
        let creditsButtonController = PrimaryButtonController(using: view.creditsButton)
        creditsButtonController.configure()
        _ = creditsButtonController
            .set(color: .purple)
            .set(label: "Credits")
        creditsButtonController.onTap {
            self.context.routeTo(.CreditsScreen)
        }
        
        remember(playButtonController)
        remember(settingsButtonController)
        remember(creditsButtonController)
    }

    private func setupAnonymousAuth() {
        GameAuth.signInAnonymously { (err) in
            print(err)
        }
    }
}

