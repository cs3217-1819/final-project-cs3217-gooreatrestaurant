//
//  OrderBlobRecipe.swift
//  slime
//
//  Created by Gabriel Tan on 23/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

struct OrderBlobRecipe {
    let goalImageName: String
    let instructionsImageNames: [String]
    
    init(goalImageName: String, instructionsImageNames: [String]) {
        self.goalImageName = goalImageName
        self.instructionsImageNames = instructionsImageNames
    }
}
