//
//  GameModel.swift
//  slime
//
//  Created by Johandy Tantra on 25/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class GameModel {
    
}

struct GamePlayerModel {
    var uid: String = ""
    var positionX: CGFloat = 0.0
    var positionY: CGFloat = 0.0
    var isHost: Bool = false
    var isConnected: Bool = false
    var holdingItem: String = ""
    var isReady: Bool = false
    
    init(uid: String, posX: CGFloat, posY: CGFloat, holdingItem: String, isHost: Bool, isConnected: Bool, isReady: Bool) {
        self.positionX = posX
        self.positionY = posY
        self.holdingItem = holdingItem
        self.isHost = isHost
        self.isConnected = isConnected
        self.isReady = isReady
    }
}

struct GameStationModel {
    var tag: String = ""
    var item: String? = ""
    var isOccupied: Bool = false
    
    init(tag: String, item: String, isOccupied: Bool) {
        self.tag = tag
        self.item = item
        self.isOccupied = isOccupied
    }
}

struct GameOrderModel {
    var id: String = ""
    var name: String = ""
    var issueTime: Double = 0.0
    var timeLimit: Double = 0.0
    
    init(id: String, name: String, issueTime: Double, timeLimit: Double) {
        self.id = id
        self.name = name
        self.issueTime = issueTime
        self.timeLimit = timeLimit
    }
}
