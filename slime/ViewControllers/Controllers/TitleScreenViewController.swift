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
        guard let character = LocalData.it.user else {
            return
        }
        let userInfoController = UserInfoController(usingXib: view.userInfoView)
        userInfoController.set(character: character)
        userInfoController.configure()
        remember(userInfoController)
    }
    
    private func setupButtons() {
        let playButtonController = PrimaryButtonController(using: view.playButton)
        playButtonController.configure()
        _ = playButtonController
            .set(color: .green)
            .set(label: "Play")
        playButtonController.onTap {
            if LocalData.it.user != nil {
                // user exists
                self.context.routeTo(.PlayScreen)
            }
            // User does not exist, create it now
            self.startCreateUserProcedure()
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
    
    private func startCreateUserProcedure() {
        // TODO: Do real character creation
        LocalData.it.createCharacter(named: "TestCharacter")
    }

    private func setupAnonymousAuth() {
        GameAuth.signInAnonymously { (err) in
            print(err)
        }
    }
}

