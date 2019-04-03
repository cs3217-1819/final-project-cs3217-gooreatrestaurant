//
//  JoinRoomViewController.swift
//  slime
//
//  Created by Gabriel Tan on 27/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class JoinRoomViewController: ViewController<JoinRoomView> {
    override func configureSubviews() {
        let codeInputController = CodeInputController(withXib: view.codeInputView)
        let numberPadController = SlimeNumberPadController(withXib: view.numPadView)
        
        codeInputController.bindTo(numberPad: numberPadController)
        codeInputController.configure()
        codeInputController.onComplete { code in
            // TODO: replace with true code
            let roomJoinId = "28280"
            
            self.showLoadingAlert(withDescription: "Teleporting slime agent...")
            
            self.context.db.joinRoom(forRoomId: roomJoinId, {
                let lobbyController: MultiplayerLobbyViewController = self.context.routeToAndPrepareFor(.MultiplayerLobby)
                lobbyController.setupRoom(withId: roomJoinId)
                self.context.modal.closeAlert()
            }, {
                // room contains 4 players already
                self.showErrorAlert(withDescription: "Room if full!")
            }, {
                // room does not exist
                self.showErrorAlert(withDescription: "Room does not exist!!")
            }, { (err) in
                self.showErrorAlert(withDescription: err as! String)
            })
        }
        numberPadController.configure()
        
        remember(codeInputController)
        remember(numberPadController)
    }
    
    private func showLoadingAlert(withDescription description: String) {
        let alert = context.modal.createAlert()
            .setTitle("Loading...")
            .setDescription(description)
        context.modal.presentUnimportantAlert(alert)
    }
    
    private func showErrorAlert(withDescription description: String) {
        let alert = context.modal.createAlert()
            .setTitle("Error!")
            .setDescription(description)
            .addAction(AlertAction(with: "OK"))
        context.modal.presentAlert(alert)
    }
}
