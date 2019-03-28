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
    var type: StageConstants.FoodType = .junk

    // the boolean is for checking whether it is processed or not
    var ingredients: [StageConstants.IngredientType: Bool] = [:]

    // bool to note success / failure
    // RI: one type of ingredient can only present once in the food
    func addIngredient(_ ingredient: Ingredient) -> Bool {
        if ingredients[ingredient.type] != nil {
            return false
        }
        // ingredients[ingredient.type] = ingredient.processed
        type = checkFoodType()
        return true
    }

    private func checkFoodType() -> StageConstants.FoodType {
        for recipe in StageConstants.recipes where recipe.ingredients == ingredients {
            return recipe.type
        }
        return .junk
    }
}
