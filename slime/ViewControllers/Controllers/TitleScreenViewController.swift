//
//  ViewController.swift
//  slime
//
//  Created by Gabriel Tan on 13/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

class TitleScreenViewController: ViewController<TitleScreenView> {
    override func configureSubviews() {
        setupUserInfo()
        setupButtons()
        setupAnonymousAuth()
    }

    private func setupUserInfo() {
        guard let charSubject = context.data.userCharacter else {
            view.userInfoView.removeFromSuperview()
            return
        }
        let userInfoController = UserInfoController(usingXib: view.userInfoView, boundTo: charSubject)
        userInfoController.configure()

        let buttonController = ButtonController(using: view.userInfoView)
        buttonController.onTap {
            self.context.routeTo(.CharacterCustomizationScreen)
        }
        remember(buttonController)
        remember(userInfoController)
    }

    private func setupButtons() {
        let playButtonController = PrimaryButtonController(using: view.playButton)
            .set(color: .green)
            .set(label: "Play")
        playButtonController.configure()
        playButtonController.onTap {
            if self.context.data.userCharacter != nil {
                // user exists
                self.context.routeTo(.PlayScreen)
            } else {
                // User does not exist, create it now
                self.context.routeTo(.CharacterCreationScreen)
            }
        }
        let settingsButtonController = PrimaryButtonController(using: view.settingsButton)
            .set(color: .blue)
            .set(label: "Settings")
        settingsButtonController.configure()
        settingsButtonController.onTap {
            self.context.routeTo(.SettingsScreen)
        }
        let creditsButtonController = PrimaryButtonController(using: view.creditsButton)
            .set(color: .purple)
            .set(label: "Credits")
        creditsButtonController.configure()
        creditsButtonController.onTap {
            self.context.routeTo(.CreditsScreen)
        }

        remember(playButtonController)
        remember(settingsButtonController)
        remember(creditsButtonController)
    }

    private func setupAnonymousAuth() {
        GameAuth.signInAnonymously { (err) in
            Logger.it.error("\(err)")
        }
    }
}
