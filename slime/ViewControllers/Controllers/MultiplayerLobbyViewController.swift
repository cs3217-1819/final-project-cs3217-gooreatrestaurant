//
//  MultiplayerLobbyViewController.swift
//  slime
//
//  Created by Gabriel Tan on 19/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//
import UIKit

class MultiplayerLobbyViewController: ViewController<MultiplayerLobbyView> {
    private lazy var playerViews: [XibView] = [
        view.playerOneView,
        view.playerTwoView,
        view.playerThreeView,
        view.playerFourView
    ]
    
    func set(roomCode: String) {
        view.roomCodeLabel.text = roomCode
    }
    
    override func configureSubviews() {
        setupPlayers()
        configureUpButton(to: .MultiplayerScreen)
    }
    
    private func setupPlayers() {
        for i in 0...3 {
            let player = Player(name: "Hello", level: i + 5)
            let control = PlayerBoxController(using: playerViews[i])
            control.setPlayer(player)
            
            remember(control)
        }
    }
}
