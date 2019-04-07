//
//  MultiplayerLobbyViewController.swift
//  slime
//
//  Created by Gabriel Tan on 19/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//
import UIKit

class MultiplayerLobbyViewController: ViewController<MultiplayerLobbyView> {
    
    var activeAlert: AlertController?
    var currentRoom: RoomModel?
    var roomId: String = ""
    
    private lazy var playerViews: [XibView] = [
        view.playerOneView,
        view.playerTwoView,
        view.playerThreeView,
        view.playerFourView
    ]
    
    private lazy var playerControllers: [PlayerBoxController] = [
        PlayerBoxController(using: playerViews[0]),
        PlayerBoxController(using: playerViews[1]),
        PlayerBoxController(using: playerViews[2]),
        PlayerBoxController(using: playerViews[3]),
    ]
    
    override func configureSubviews() {
        configureUpButton(to: .MultiplayerScreen)
        for controller in playerControllers {
            controller.configure()
        }
    }
    
    private func setupPlayers(forPlayers players: [RoomPlayerModel]) {
        let playerCount = players.count
        for i in 0..<playerViews.count {
            if i >= playerCount {
                playerControllers[i].removePlayer()
                continue
            }
            
            let roomPlayer = Player(from: players[i])
            playerControllers[i].setPlayer(roomPlayer)
        }
    }
    
    private func setupRoomDetails(forRoom room: RoomModel) {
        // TODO:
        view.roomCodeLabel.text = room.id
        self.currentRoom = room
    }
    
    func setupRoom(withId id: String) {
        self.roomId = id
        self.context.db.observeRoomState(forRoomId: id, { (room) in
            self.setupPlayers(forPlayers: room.players)
            self.setupRoomDetails(forRoom: room)
            
            if room.gameIsCreated {
                self.setLoadingAlert(withDescription: "Pumping slimes into spaceship...")
                self.presentActiveAlert(dismissible: false)
                
                self.context.db.removeAllObservers()
                
                // TODO: route to game room
                
                return
            }
            
            if room.hasStarted {
                self.setLoadingAlert(withDescription: "Spaceship is ready, just tidying up a few things...")
                self.presentActiveAlert(dismissible: false)
            }
        }, {
            // room has been closed by host or
            // host left the room
            self.setErrorAlert(withDescription: "The host has left the room...")
            self.presentActiveAlert(dismissible: true)
            self.context.routeTo(.MultiplayerScreen)
        }) { (err) in
            self.setErrorAlert(withDescription: err as! String)
            self.presentActiveAlert(dismissible: true)
        }
    }
    
    private func startGame() {
        if !allPlayersReady() {
            return
        }
        
        guard let room = self.currentRoom else {
            return
        }
        
        self.context.db.startGame(forRoom: room, {
            // do something
        }) { (err) in
            self.setErrorAlert(withDescription: err as! String)
            self.presentActiveAlert(dismissible: true)
        }
    }
    
    private func allPlayersReady() -> Bool {
        guard let room = currentRoom else {
            return false
        }
        
        for player in room.players {
            if !player.isHost && !player.isReady {
                return false
            }
        }
        
        return true
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
    
    private func setWarningAlert(to description: String, withOkCallback: @escaping () -> Void) {
        self.activeAlert = self.context.modal.createAlert()
            .setTitle("Warning!!")
            .setDescription(description)
            .addAction(AlertAction(with: "CANCEL"))
            .addAction(AlertAction(with: "OK", callback: withOkCallback))
    }
    
    private func setErrorAlert(withDescription description: String) {
        self.activeAlert = self.context.modal.createAlert()
            .setTitle("Error!")
            .setDescription(description)
            .addAction(AlertAction(with: "OK"))
    }
    
    override func configureUpButton(to route: Route) {
        let upButton = UIView.initFromNib("UpButton")
        let control = ButtonController(using: upButton)
        
        control.onTap {
            self.setWarningAlert(to: "Leave the room?", withOkCallback: {
                self.leaveRoomAndRoute(to: route)
            })
            self.presentActiveAlert(dismissible: true)
        }
        
        view.addSubview(upButton)
        upButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
        
        remember(control)
        view.layoutIfNeeded()
    }
    
    private func leaveRoomAndRoute(to route: Route) {
        self.context.db.leaveRoom(fromRoomId: self.roomId, {
            self.context.routeTo(route)
            self.context.db.removeAllObservers()
        }, { (err) in
            self.setErrorAlert(withDescription: err as! String)
            self.presentActiveAlert(dismissible: true)
        })
    }
}
