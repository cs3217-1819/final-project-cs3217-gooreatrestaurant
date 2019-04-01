//
//  Food.swift
//  GooreatRestaurant
//
//  Created by Samuel Henry Kurniawan on 14/3/19.
//  Copyright © 2019 CS3217. All rights reserved.
//

import UIKit
import SpriteKit

class Food {
    private(set) var ingredientsList: [IngredientData:Int] = [:]

    func addIngredients(_ ingredient: Ingredient) {

        let ingredientData = IngredientData(type: ingredient.type, processed: ingredient.processed)

        if ingredientsList[ingredientData] == nil {
            ingredientsList[ingredientData] = 0
        }
        ingredientsList[ingredientData]? += 1
    }
}
