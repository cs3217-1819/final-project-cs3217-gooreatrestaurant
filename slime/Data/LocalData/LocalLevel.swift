//
//  LocalLevel.swift
//  slime
//
//  Created by Gabriel Tan on 15/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import RealmSwift

class LocalLevelScore: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var bestScore: Int = 0
    
    override static func primaryKey() -> String? {
        print("test")
        return "id"
    }
}
