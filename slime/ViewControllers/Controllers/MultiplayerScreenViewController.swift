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
            
            self.context.db.createRoom(withRoomName: "Pros only", withMap: "Chaos", { id in
                self.context.closeAlert()
                
                let vc: MultiplayerLobbyViewController = self.context.routeToAndPrepareFor(.MultiplayerLobby)
                vc.setupRoom(withId: id)
            }, { (err) in
                self.setErrorAlert(withDescription: err as! String)
                self.presentActiveAlert(dismissible: true)
            })
        }
        let joinControl = ButtonController(using: view.joinRoomButton)
        joinControl.onTap {
            // TODO: show dialog box to add room id
            let roomJoinId = "28280"
            
            self.setLoadingAlert(withDescription: "Teleporting slime agent...")
            self.presentActiveAlert(dismissible: true)
            
            self.context.db.joinRoom(forRoomId: roomJoinId, {
                let vc: MultiplayerLobbyViewController = self.context.routeToAndPrepareFor(.MultiplayerLobby)
                vc.setupRoom(withId: roomJoinId)
                
                self.context.closeAlert()
            }, {
                // room contains 4 players already
                self.setErrorAlert(withDescription: "Room if full!")
                self.presentActiveAlert(dismissible: true)
            }, {
                // room does not exist
                self.setErrorAlert(withDescription: "Room does not exist!!")
                self.presentActiveAlert(dismissible: true)
            }, { (err) in
                self.setErrorAlert(withDescription: err as! String)
                self.presentActiveAlert(dismissible: true)
            })
        }
        
        remember(hostControl)
        remember(joinControl)
    }
    
    private func presentActiveAlert(dismissible: Bool) {
        guard let alert = self.activeAlert else {
            return
        }
        
        if dismissible {
            self.context.presentUnimportantAlert(alert)
            return
        }
        
        self.context.presentAlert(alert)
    }
    
    private func setLoadingAlert(withDescription description: String) {
        self.activeAlert = self.context.createAlert()
            .setTitle("Loading...")
            .setDescription(description)
    }
    
    private func setErrorAlert(withDescription description: String) {
        self.activeAlert = self.context.createAlert()
            .setTitle("Error!")
            .setDescription(description)
            .addAction(AlertAction(with: "OK"))
    }
}
