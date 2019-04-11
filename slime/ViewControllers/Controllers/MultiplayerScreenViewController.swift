//
//  MultiplayerScreenViewController.swift
//  slime
//
//  Created by Gabriel Tan on 19/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//
import UIKit

class MultiplayerScreenViewController: ViewController<MultiplayerScreenView> {

    var activeAlert: AlertController?

    override func configureSubviews() {
        setupButtons()
        configureUpButton(to: .PlayScreen)
    }

    private func setupButtons() {
        let hostControl = ButtonController(using: view.hostRoomButton)
        hostControl.onTap {
            self.setLoadingAlert(withDescription: "Preparing the spaceship...")
            self.presentActiveAlert(dismissible: false)

            guard let userCharacter = try? self.context.data.userCharacter?.value() else {
                return
            }
            
            guard let userChar = userCharacter else {
                return
            }
            
            print(userChar.accessory)
            print(userChar.hat)
            print(userChar.name)
            print(userChar.color.toString())
            self.context.db.createRoom(withRoomName: "Pros only", withMap: "Level1", withUser: userChar, { id in
                self.context.modal.closeAlert()

                let vc: MultiplayerLobbyViewController = self.context.routeToAndPrepareFor(.MultiplayerLobby)
                vc.setupRoom(withId: id)
            }, { (err) in
                self.setErrorAlert(withDescription: err as! String)
                self.presentActiveAlert(dismissible: true)
            })
        }
        let joinControl = ButtonController(using: view.joinRoomButton)
        joinControl.onTap {
            self.context.routeTo(.MultiplayerJoinRoomScreen)
        }

        remember(hostControl)
        remember(joinControl)
    }

    private func presentActiveAlert(dismissible: Bool) {
        guard let alert = self.activeAlert else {
            return
        }

        if dismissible {
            self.context.modal.presentUnimportantAlert(alert)
            return
        }

        self.context.modal.presentAlert(alert)
    }

    private func setLoadingAlert(withDescription description: String) {
        self.activeAlert = self.context.modal.createAlert()
            .setTitle("Loading...")
            .setDescription(description)
    }

    private func setErrorAlert(withDescription description: String) {
        self.activeAlert = self.context.modal.createAlert()
            .setTitle("Error!")
            .setDescription(description)
            .addAction(AlertAction(with: "OK"))
    }
}
