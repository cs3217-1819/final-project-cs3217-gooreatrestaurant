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
            let lobbyController: MultiplayerLobbyViewController = self.context.routeToAndPrepareFor(.MultiplayerLobby)
            lobbyController.setupRoom(withId: code)
        }
        numberPadController.configure()
        
        remember(codeInputController)
        remember(numberPadController)
    }
}
