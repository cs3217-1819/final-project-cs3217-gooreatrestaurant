//
//  Food.swift
//  GooreatRestaurant
//
//  Created by Samuel Henry Kurniawan on 14/3/19.
//  Copyright © 2019 CS3217. All rights reserved.
//

import UIKit
import SpriteKit

class Food: NSObject {
    private(set) var ingredientsList: [Ingredient : Int] = [:]

    init() {
        super.init()
    }

    func addIngredients(_ ingredient: Ingredient) {
        if ingredientsList[ingredient] == nil {
            ingredientsList[ingredient] = 1
        } else {
            ingredientsList[ingredient] += 1
        }
    }
}
