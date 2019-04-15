//
//  Level.swift
//  slime
//
//  Created by Gabriel Tan on 15/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//
import Foundation

struct Level {
    var id: String
    var name: String
    var fileName: String
    var bestScore: Int

    init(id: String, name: String, fileName: String, bestScore: Int) {
        self.id = id
        self.name = name
        self.fileName = fileName
        self.bestScore = bestScore
    }
}

struct SavedLevel: Codable {
    var id: String
    var name: String
    var fileName: String
}

struct LevelsProvider: Codable {
    var levels: [SavedLevel]
}

class LevelsReader {
    private init() {
        
    }
    
    public static func readMultiplayerLevels() -> [Level] {
        guard let levelsProvider = LevelsReader.readLevelsData(fileName: "MultiplayerLevels") else {
            return []
        }
        
        var levels: [Level] = []
        for savedLevel in levelsProvider.levels {
            let level = Level(id: savedLevel.id,
                              name: savedLevel.name,
                              fileName: savedLevel.fileName,
                              bestScore: 0)
            levels.append(level)
        }
        return levels
    }
    
    public static func readSinglePlayerLevels() -> [Level] {
        guard let levelsProvider = LevelsReader.readLevelsData(fileName: "SinglePlayerLevels") else {
            return []
        }
        
        var levels: [Level] = []
        for savedLevel in levelsProvider.levels {
            let level = Level(id: savedLevel.id,
                              name: savedLevel.name,
                              fileName: savedLevel.fileName,
                              bestScore: LocalData.it.getBestScoreFor(level: savedLevel.id))
            levels.append(level)
        }
        return levels
    }
    
    private static func readLevelsData(fileName: String) -> LevelsProvider? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            return nil
        }
        guard let data = try? Data(contentsOf: url) else {
            // file does not exist
            return nil
        }
        let decoder = JSONDecoder()
        let levels = try? decoder.decode(LevelsProvider.self, from: data)
        return levels
    }
}
