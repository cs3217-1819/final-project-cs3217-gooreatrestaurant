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
        guard let charSubject = context.userCharacter else {
            return
        }
        let userInfoController = UserInfoController(usingXib: view.userInfoView, boundTo: charSubject)
        userInfoController.configure()
        remember(userInfoController)
    }
    
    private func setupButtons() {
        let playButtonController = PrimaryButtonController(using: view.playButton)
            .set(color: .green)
            .set(label: "Play")
        playButtonController.configure()
        playButtonController.onTap {
            if self.context.userCharacter != nil {
                // user exists
                self.context.routeTo(.PlayScreen)
            }
            // User does not exist, create it now
            self.startCreateUserProcedure()
        }
        let settingsButtonController = PrimaryButtonController(using: view.settingsButton)
            .set(color: .blue)
            .set(label: "Settings")
        settingsButtonController.configure()
        settingsButtonController.onTap {
            self.context.gainCharacterExp(10)
            // self.context.routeTo(.SettingsScreen)
        }
        let creditsButtonController = PrimaryButtonController(using: view.creditsButton)
            .set(color: .purple)
            .set(label: "Credits")
        creditsButtonController.configure()
        creditsButtonController.onTap {
            self.context.routeTo(.CharacterCreationScreen)
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

