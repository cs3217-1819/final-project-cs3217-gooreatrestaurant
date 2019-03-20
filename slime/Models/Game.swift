//
//  Game.swift
//  GooreatRestaurant
//
//  Created by Samuel Henry Kurniawan on 14/3/19.
//  Copyright © 2019 CS3217. All rights reserved.
//

import UIKit

class Game: NSObject {
    private var stageDictionary: [String: Stage] = [:]
    var stagePlaying: Stage?

    func addStage(_ stage: Stage = Stage(), withName name: String) {
        stageDictionary[name] = stage
    }

    // if not found, do nothing
    func removeStage(withName name: String) {
        _ = stageDictionary.removeValue(forKey: name)
    }

    func getStage(withName name: String) -> Stage? {
        return stageDictionary[name]
    }

    var stageNames: [String] {
        return Array(stageDictionary.keys)
    }

    var stageLists: [Stage] {
        return Array(stageDictionary.values)
    }

    // return true if success, false if failed
    func playStage(withName name: String) -> Bool {
        guard let stageToPlay = stageDictionary[name] else {
            return false
        }

        stagePlaying = Stage(size: stageToPlay.size)
        return true
    }
}
