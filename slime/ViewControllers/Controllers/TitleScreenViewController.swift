//
//  ViewController.swift
//  slime
//
//  Created by Gabriel Tan on 13/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

class TitleScreenViewController: ViewController<TitleScreenView> {
    var activeAlert: AlertController?
    
    override func configureSubviews() {
        setupUserInfo()
        setupButtons()
        setupAnonymousAuth()
        checkForRejoins()
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
    
    private func checkForRejoins() {
        self.context.db.checkRejoinGame({ (gameId) in
            self.setRejoinAlert(to: "You were disconnected from an on-going game with code \(gameId). Do you want to rejoin this game?", withOkCallback: {
                self.context.db.rejoinGame(forGameId: gameId, { (room) in
                    self.setLoadingAlert(withDescription: "Teleporting slime agent...")
                    self.presentActiveAlert(dismissible: false)
                    self.context.segueToMultiplayerGame(forRoom: room)
                }, { (err) in
                    Logger.it.error("\(err)")
                })
            }, withCancelCallback: {
                self.context.db.cancelRejoinGame({ }, { (err) in
                    Logger.it.error("\(err)")
                })
            })
            self.presentActiveAlert(dismissible: false)
        }) { (err) in
            Logger.it.error("\(err)")
        }
    }
    
    private func presentActiveAlert(dismissible: Bool) {
        guard let alert = self.activeAlert else { return }
        if dismissible {
            self.context.modal.presentUnimportantAlert(alert)
            return
        }

        self.context.modal.presentAlert(alert)
    }
    
    private func setRejoinAlert(to description: String, withOkCallback: @escaping () -> Void, withCancelCallback: @escaping () -> Void) {
        self.activeAlert = self.context.modal.createAlert()
            .setTitle("HEY YOU!!")
            .setDescription(description)
            .addAction(AlertAction(with: "NO", callback: withCancelCallback, of: .Success))
            .addAction(AlertAction(with: "YES PLZ", callback: withOkCallback, of: .Success))
    }
    
    private func setLoadingAlert(withDescription description: String) {
        self.activeAlert = self.context.modal.createAlert()
            .setTitle("Loading...")
            .setDescription(description)
    }
}
