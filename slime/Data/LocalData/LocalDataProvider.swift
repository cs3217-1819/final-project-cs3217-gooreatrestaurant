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
    
    func readLevelBestScore(id: String) -> Int {
        guard let levelScore = realm.object(ofType: LocalLevelScore.self, forPrimaryKey: id) else {
            return 0
        }
        return levelScore.bestScore
    }
    
    func saveLevelData(level: Level, bestScore: Int) {
        if level.bestScore >= bestScore {
            // Ignore requests to write a lower best score
            return
        }
        let savedLevel = LocalLevelScore()
        savedLevel.id = level.id
        savedLevel.bestScore = bestScore
        try! realm.write {
            self.realm.add(savedLevel, update: true)
        }
    }

    func reset() {
        try! realm.write {
            realm.deleteAll()
        }
    }
}
