//
//  LocalUserCharacter.swift
//  slime
//
//  Created by Gabriel Tan on 30/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import RealmSwift

class LocalUserCharacter: Object {
    @objc dynamic var id: Int = 1 // ID 1 belongs to the local user
    @objc dynamic var name: String = ""
    @objc dynamic var level: Int = 1
    @objc dynamic var exp: Int = 0
    @objc dynamic var color: SlimeColor = .yellow
    @objc dynamic var hat: String = "none"
    @objc dynamic var accessory: String = "none"

    override static func primaryKey() -> String? {
        return "id"
    }
}

class UserCharacter {
    private(set) var color: SlimeColor
    private(set) var name: String
    private(set) var level: Int
    private(set) var exp: Int
    private(set) var hat: String
    private(set) var accessory: String
    
    init(from char: LocalUserCharacter) {
        name = char.name
        level = char.level
        exp = char.exp
        color = char.color
        hat = char.hat
        accessory = char.accessory
    }
    
    init(from char: Player) {
        name = char.name
        level = char.level
        exp = 0
        color = char.color
        hat = char.hat
        accessory = char.accessory
    }

    init(named name: String) {
        self.name = name
        level = 1
        exp = 0
        color = .yellow
        hat = "none"
        accessory = "none"
    }

    func gainExp(_ gainedExp: Int) {
        exp += gainedExp
        // TODO: Implement a level up system
        while exp >= 100 {
            exp -= 100
            level += 1
        }
    }

    func set(color: SlimeColor) {
        self.color = color
    }
    
    func setHat(_ name: String) {
        hat = name
    }
    
    func setAccessory(_ name: String) {
        accessory = name
    }

    func asLocalDataType() -> LocalUserCharacter {
        let char = LocalUserCharacter()
        char.name = name
        char.level = level
        char.exp = exp
        char.color = color
        char.hat = hat
        char.accessory = accessory
        return char
    }
}
