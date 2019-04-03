//
//  LocalDataProvider.swift
//  slime
//
//  Created by Gabriel Tan on 30/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import RealmSwift

/**
 * LocalDataProvider interfaces with 3rd-party libraries which handle
 * local persistent data storage
 */
class LocalDataProvider {
    static let it: LocalDataProvider = LocalDataProvider()
    private let realm: Realm
    private init() {
        realm = try! Realm()
    }
    
    func getUser() -> UserCharacter? {
        guard let user = realm.object(ofType: LocalUserCharacter.self, forPrimaryKey: 1) else {
            return nil
        }
        return UserCharacter(from: user)
    }
    
    func save(user: UserCharacter) {
        try! realm.write {
            self.realm.add(user.asLocalDataType(), update: true)
        }
    }
}
