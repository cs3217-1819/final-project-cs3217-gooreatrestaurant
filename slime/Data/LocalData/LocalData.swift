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
    private(set) var user: UserCharacter?
    
    private init() {
        user = LocalDataProvider.it.getUser()
    }
    
    func createCharacter(named name: String) {
        guard self.user == nil else {
            // User already exists
            return
        }
        let user = UserCharacter(named: name)
        LocalDataProvider.it.save(user: user)
        
        self.user = LocalDataProvider.it.getUser()
    }
    
    func saveCharacter() {
        guard let characterToSave = user else {
            // No user exists
            return
        }
        LocalDataProvider.it.save(user: characterToSave)
    }
}
