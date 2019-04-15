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

struct ItemModel {
    var type: String = "none"
    var encodedData: String = "none"
    
    init(type: String, encodedData: String) {
        self.type = type
        self.encodedData = encodedData
    }
}

struct GamePlayerModel {
    var uid: String = ""
    var positionX: CGFloat = 0.0
    var positionY: CGFloat = 0.0
    var velocityX: CGFloat = 0.0
    var velocityY: CGFloat = 0.0
    var xScale: CGFloat = 0.0
    var isHost: Bool = false
    var isConnected: Bool = false
    var holdingItem: ItemModel = ItemModel(type: "none", encodedData: "none")
    var isReady: Bool = false
    var name: String = ""
    var hat: String = "none"
    var accessory: String = "none"
    var color: String = "green"
    var level: Int = 1

    init(uid: String, posX: CGFloat, posY: CGFloat, vx: CGFloat, vy: CGFloat, xScale: CGFloat, holdingItem: ItemModel, isHost: Bool, isConnected: Bool, isReady: Bool, name: String, hat: String, accessory: String, color: String, level: Int) {
        self.positionX = posX
        self.positionY = posY
        self.velocityX = vx
        self.velocityY = vy
        self.xScale = xScale
        self.holdingItem = holdingItem
        self.isHost = isHost
        self.isConnected = isConnected
        self.isReady = isReady
        self.name = name
        self.hat = hat
        self.color = color
        self.accessory = accessory
        self.level = level
        self.uid = uid
    }
}

struct GameStationModel {
    var type: String = ""
    var item: ItemModel = ItemModel(type: "none", encodedData: "none")
    var isOccupied: Bool = false

    init(type: String, item: ItemModel, isOccupied: Bool) {
        self.type = type
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

struct NotificationModel {
    var description: String = ""
    var type: String = ""
    
    init(description: String, type: String) {
        self.description = description
        self.type = type
    }
}

struct StageItemModel {
    var uid: String = ""
    var encodedData: String = ""
    var type: String = ""
    
    init(uid: String, encodedData: String, type: String) {
        self.uid = uid
        self.encodedData = encodedData
        self.type = type
    }
}
