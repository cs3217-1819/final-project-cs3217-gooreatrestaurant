//
//  RoomModel.swift
//  slime
//
//  Created by Johandy Tantra on 25/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

class RoomModel {
    var name: String = ""
    var map: String = ""
    var id: String = ""
    var players: [RoomPlayerModel] = []
    var hasStarted: Bool = false
    var gameIsCreated: Bool = false
    var isOpen: Bool = false

    init(name: String, map: String, id: String, hasStarted: Bool, gameIsCreated: Bool, isOpen: Bool) {
        self.name = name
        self.map = map
        self.id = id
        self.hasStarted = hasStarted
        self.gameIsCreated = gameIsCreated
        self.isOpen = isOpen
    }

    func isValidRoom() -> Bool {
        if self.name.count <= 0 || self.map.count <= 0 {
            return false
        }

        // do additional checks here
        return true
    }

    func addPlayer(_ player: RoomPlayerModel) {
        players.append(player)
    }

    func startGame() {
        self.hasStarted = true
    }

    func toString() -> String {
        return "name: \(self.name)\nmap: \(self.map)\nid: \(self.id)\nplayers: \(self.players)\nhasStarted: \(self.hasStarted)\ngameIsCreated: \(self.gameIsCreated)"
    }
}

class RoomPlayerModel {
    var uid: String = ""
    var isHost: Bool = false
    var isReady: Bool = false
    // TODO: replace with name of player, generated or otherwise
    var name: String {
        return uid
    }

    init(uid: String, isHost: Bool, isReady: Bool) {
        self.uid = uid
        self.isHost = isHost
        self.isReady = isReady
    }
}
