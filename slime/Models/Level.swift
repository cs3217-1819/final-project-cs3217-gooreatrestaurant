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
    var preview: String

    init(id: String, name: String, fileName: String, bestScore: Int, preview: String) {
        self.id = id
        self.name = name
        self.fileName = fileName
        self.bestScore = bestScore
        self.preview = preview
    }
}

struct SavedLevel: Codable {
    var id: String
    var name: String
    var fileName: String
    var preview: String
}

struct LevelsProvider: Codable {
    var levels: [SavedLevel]
}

class LevelsReader {
    private static var multiplayerLevels: [Level]?
    private static var singlePlayerLevels: [Level]?
    private init() {
        
    }
    
    public static func getLevel(id: String) -> Level? {
        let levels = LevelsReader.readMultiplayerLevels()
        for level in levels {
            if level.id == id {
                return level
            }
        }
        return nil
    }
    
    public static func readMultiplayerLevels() -> [Level] {
        if let cachedLevels = LevelsReader.multiplayerLevels {
            return cachedLevels
        }
        guard let levelsProvider = LevelsReader.readLevelsData(fileName: "MultiplayerLevels") else {
            Logger.it.info("Could not find any multiplayer levels")
            return []
        }
        
        var levels: [Level] = []
        for savedLevel in levelsProvider.levels {
            let level = Level(id: savedLevel.id,
                              name: savedLevel.name,
                              fileName: savedLevel.fileName,
                              bestScore: 0,
                              preview: savedLevel.preview)
            levels.append(level)
        }
        LevelsReader.multiplayerLevels = levels
        return levels
    }
    
    public static func readSinglePlayerLevels() -> [Level] {
        if let cachedLevels = LevelsReader.singlePlayerLevels {
            return cachedLevels
        }
        guard let levelsProvider = LevelsReader.readLevelsData(fileName: "SinglePlayerLevels") else {
            return []
        }
        
        var levels: [Level] = []
        for savedLevel in levelsProvider.levels {
            let level = Level(id: savedLevel.id,
                              name: savedLevel.name,
                              fileName: savedLevel.fileName,
                              bestScore: LocalData.it.getBestScoreFor(level: savedLevel.id),
                              preview: savedLevel.preview)
            levels.append(level)
        }
        LevelsReader.singlePlayerLevels = levels
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
