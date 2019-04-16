//
//  MultiplayerLobbyViewController.swift
//  slime
//
//  Created by Gabriel Tan on 19/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//
import UIKit

class MultiplayerLobbyViewController: ViewController<MultiplayerLobbyView> {
    private var selectorController: StageSelectorController?
    private var stagePreviewController: StagePreviewController?
    private var changeButtonListener: PrimaryButtonController?
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
        PlayerBoxController(using: playerViews[3])
    ]

    override func configureSubviews() {
        configureUpButton(to: .MultiplayerScreen)
        setupStartButton()
        setupStagePreview()
        for controller in playerControllers {
            controller.configure()
        }
    }
    
    private func setupStagePreview() {
        let stagePreviewControl = StagePreviewController(with: view.stagePreviewView)
        stagePreviewControl.setBackgroundName(name: "background-1")
        if let map = currentRoom?.map {
            setStagePreviewImage(for: map)
        }
        stagePreviewController = stagePreviewControl
        stagePreviewControl.configure()
    }
    
    private func showStartButton() {
        view.startButton.alpha = 1
        view.startButton.isUserInteractionEnabled = true
    }
    
    private func hideStartButton() {
        view.startButton.alpha = 0
        view.startButton.isUserInteractionEnabled = false
    }
    
    private func hideChangeMapButton() {
        view.stageChangeButton.alpha = 0
    }
    
    private func setupChangeMapButton() {
        if changeButtonListener != nil {
            return
        }
        let buttonController = PrimaryButtonController(usingXib: view.stageChangeButton)
            .set(label: "Change")
            .set(color: .purple)
            .set(style: "hsub")
        
        buttonController.configure()
        buttonController.onTap {
            guard self.isHost() else {
                return
            }
            let modalView = UIView.initFromNib("StageSelectModal") as! StageSelectModal
            modalView.snp.makeConstraints { make in
                make.width.equalTo(450)
                make.height.equalTo(300)
            }
            modalView.layoutIfNeeded()
            let control = StageSelectorController(withXib: modalView.levelPreviewsView)
            control.levels = LevelsReader.readMultiplayerLevels()
            control.onSelect { level in
                self.context.db.changeRoomMap(fromRoomId: self.roomId, toMapId: level.id, { error in
                    fatalError(error.localizedDescription)
                })
                self.context.modal.closeAlert()
            }
            control.configure()
            self.context.modal.showModal(view: modalView)
            self.selectorController = control
        }
        
        changeButtonListener = buttonController
    }
    
    private func setStagePreviewImage(for id: String) {
        guard let level = LevelsReader.getLevel(id: id) else {
            return
        }
        
        stagePreviewController?.setStageName(name: level.preview)
    }

    private func setupPlayers(forPlayers players: [RoomPlayerModel]) {
        AudioMaster.instance.playSFX(name: "joinroom")
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
        view.roomCodeLabel.text = room.id
        self.currentRoom = room
        setStagePreviewImage(for: room.map)
    }

    func setupRoom(withId id: String) {
        self.roomId = id
        self.context.db.observeRoomState(forRoomId: id, { (room) in
            self.setupPlayers(forPlayers: room.players)
            self.setupRoomDetails(forRoom: room)
            if self.isHost() {
                self.setupChangeMapButton()
                self.showStartButton()
            } else {
                self.hideChangeMapButton()
                self.hideStartButton()
            }

            if room.gameIsCreated {
                self.context.modal.closeAlert()
                self.setLoadingAlert(withDescription: "Pumping slimes into spaceship...")
                self.presentActiveAlert(dismissible: false)

                self.context.db.removeAllObservers()
                self.context.db.removeAllDisconnectObservers()

                AudioMaster.instance.playSFX(name: "done-loading")
                guard let level = LevelsReader.getLevel(id: room.map) else {
                    fatalError("no such level lol")
                }
                self.context.segueToMultiplayerGame(forRoom: room, level: level)
                return
            }

            if room.hasStarted {
                AudioMaster.instance.playSFX(name: "done-loading")
                self.setLoadingAlert(withDescription: "Spaceship is ready, just tidying up a few things...")
                self.presentActiveAlert(dismissible: false)
            }
        }, {
            // room has been closed by host or
            // host left the room
            AudioMaster.instance.playSFX(name: "error")
            self.setErrorAlert(withDescription: "The host has left the room...")
            self.presentActiveAlert(dismissible: true)
            self.context.routeTo(.MultiplayerScreen)
        }) { (err) in
            self.setErrorAlert(withDescription: err.localizedDescription)
            self.presentActiveAlert(dismissible: true)
        }
    }
    
    private func setupStartButton() {
        let controller = PrimaryButtonController(usingXib: view.startButton)
            .set(label: "Start")
            .set(color: .green)
        controller.onTap {
            self.startGame()
        }
        
        controller.configure()
        
        remember(controller)
    }

    private func startGame() {
//        if !allPlayersReady() { return }
        if !isHost() { return }

        guard let room = self.currentRoom else { return }

        self.context.db.startGame(forRoom: room, {
            // do something
        }) { (err) in
            self.setErrorAlert(withDescription: err.localizedDescription)
            self.presentActiveAlert(dismissible: true)
        }
    }

    private func isHost() -> Bool {
        guard let room = self.currentRoom else {
            return false
        }

        guard let user = GameAuth.currentUser else {
            return false
        }

        for player in room.players {
            if player.uid == user.uid {
                return player.isHost
            }
        }

        return false
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
            .addAction(AlertAction(with: "OK", callback: withOkCallback, of: .Success))
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
        control.sound = "back"
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
            self.context.db.removeAllDisconnectObservers()
        }, { (err) in
            self.setErrorAlert(withDescription: err.localizedDescription)
            self.presentActiveAlert(dismissible: true)
        })
    }
}
