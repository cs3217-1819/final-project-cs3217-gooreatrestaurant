//
//  MultiplayerScreenViewController.swift
//  slime
//
//  Created by Gabriel Tan on 19/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//
import UIKit

class MultiplayerScreenViewController: ViewController<MultiplayerScreenView> {
    override func configureSubviews() {
        setupButtons()
        configureUpButton(to: .PlayScreen)
    }
    
    private func setupButtons() {
        let hostControl = ButtonController(using: view.hostRoomButton)
        hostControl.onTap {
            self.context.routeTo(.MultiplayerLobby)
        }
        let joinControl = ButtonController(using: view.joinRoomButton)
        joinControl.onTap {
            self.context.routeTo(.MultiplayerLobby)
        }
        
        remember(hostControl)
        remember(joinControl)
    }
}
