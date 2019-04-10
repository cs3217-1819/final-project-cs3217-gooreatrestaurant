//
//  Player.swift
//  slime
//
//  Created by Gabriel Tan on 19/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import Foundation
import UIKit

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
        level = 1
        isHost = model.isHost
        hat = "none"
        accessory = "none"
        color = .yellow
    }
    
}
