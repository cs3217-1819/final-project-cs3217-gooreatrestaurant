//
//  User.swift
//  slime
//
//  Created by Johandy Tantra on 10/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

struct UserModel {
    var name: String = "Generic Slime"
    var level: Int = 1
    var hat: String = "none"
    var accessory: String = "none"
    var color: String = "green"
    
    init(name: String, level: Int, hat: String, accessory: String, color: String) {
        self.name = name
        self.level = level
        self.hat = hat
        self.accessory = accessory
        self.color = color
    }
}
