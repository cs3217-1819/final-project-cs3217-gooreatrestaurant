//
//  Level.swift
//  slime
//
//  Created by Gabriel Tan on 15/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

struct Level: Codable {
    var id: String
    var name: String
    var bestScore: Int
    
    init(id: String, name: String, bestScore: Int) {
        self.id = id
        self.name = name
        self.bestScore = bestScore
    }
}
