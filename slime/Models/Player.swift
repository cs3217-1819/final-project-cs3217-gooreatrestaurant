//
//  Player.swift
//  slime
//
//  Created by Gabriel Tan on 19/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import Foundation
import UIKit

// Player object for displaying in the UI.
class Player: NSObject {
    var isHost = false
    var name: String
    var level: Int
    var hat: String
    var accessory: String
    var color: SlimeColor

    init(name: String, level: Int) {
        self.name = name
        self.level = level
        hat = "none"
        accessory = "none"
        color = .yellow
    }

    init(from model: RoomPlayerModel) {
        name = model.name
        level = model.level
        isHost = model.isHost
        hat = model.hat
        accessory = model.accessory
        color = SlimeColor(fromString: model.color)
    }
    
    init(from character: UserCharacter) {
        name = character.name
        level = character.level
        hat = character.hat
        accessory = character.accessory
        color = character.color
    }
    
}
