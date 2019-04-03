//
//  LocalData.swift
//  slime
//
//  Created by Gabriel Tan on 30/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import Foundation

/**
 * LocalData is what regular classes should interface with to retrieve local data.
 * It interacts with the LocalDataProvider to retrieve data.
 */
class LocalData {
    static let it = LocalData()
    
    private init() {
        
    }
    
    func getUserCharacter() -> UserCharacter? {
        return LocalDataProvider.it.getUser()
    }
    
    func createCharacter(named name: String) {
        let user = UserCharacter(named: name)
        LocalDataProvider.it.save(user: user)
    }
    
    func saveCharacter(_ characterToSave: UserCharacter) {
        LocalDataProvider.it.save(user: characterToSave)
    }
    
    func resetData() {
        LocalDataProvider.it.reset()
    }
}
