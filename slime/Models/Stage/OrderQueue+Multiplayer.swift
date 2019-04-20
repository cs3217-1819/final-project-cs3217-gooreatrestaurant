//
//  OrderQueue+Multiplayer.swift
//  slime
//
//  Created by Johandy Tantra on 19/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import Foundation

extension OrderQueue {
    func setMultiplayerTimeout(forRecipe recipe: Recipe) {
        if !self.isMultiplayerEnabled { return }
        
        self.multiplayerUpdateSelf()
        self.sendNotification(withDescription: "oops! you missed the \(recipe.recipeName) order!", withType: NotificationPrefab.NotificationTypes.warning.rawValue)
    }
    
    func multiplayerAddScore(by score: Int) {
        if !self.isMultiplayerEnabled { return }
        
        let db = GameDB()
        guard let id = gameId else { return }
        db.addScore(by: scoreToIncrease, forGameId: id, { }) { (err) in
            print(err.localizedDescription)
        }
    }
    
    func sendNotification(withDescription description: String, withType type: String = NotificationPrefab.NotificationTypes.info.rawValue) {
        let database = GameDB()
        guard let id = self.gameId else { return }
        database.sendNotification(forGameId: id, withDescription: description, withType: type, { }) { (err) in
            print(err.localizedDescription)
        }
    }
    
    func multiplayerAddRandomOrder() {
        if !isMultiplayerEnabled { return }
        guard let recipe = self.generateRandomRecipe() else { return }
        self.addOrder(ofRecipe: recipe)
    
        multiplayerUpdateSelf()
        sendNotification(withDescription: "someone ordered \(recipe.recipeName), chop chop!")
    }
    
    func multiplayerUpdateSelf() {
        let db = GameDB()
        guard let id = gameId else { return }
        db.updateOrderQueue(forGameId: id, withOrderQueue: self, { }) { (err) in
            print(err.localizedDescription)
        }
    }
}
