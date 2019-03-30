//
//  Recipe.swift
//  slime
//
//  Created by Samuel Henry Kurniawan on 28/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class Recipe: NSObject {
    private(set) var ingredientsNeeded: [Ingredient:Int] = [:]

    init(withCompulsoryIngredients compulsoryIngredients: [IngredientType],
         withOptionalIngredients optionalIngredients: [(type: IngredientType, probability: Double)]) {

        var ingredientsRequirement = compulsoryIngredients

        for ingredientData in optionalIngredients {
            let ingredientType = ingredientData.type
            let probability = ingredientData.probability

            guard drand48() < probability else {
                continue
            }

            ingredientsRequirement.append(ingredientType)
        }

        for ingredientType in ingredientsRequirement {
            let ingredient = Ingredient(type: ingredientType)

            if ingredientsNeeded[ingredient] == nil {
                ingredientsNeeded[ingredient] = 0
            }

            ingredientsNeeded[ingredient]? += 1
        }

        super.init()
    }

    convenience init(withCompulsoryIngredients compulsoryIngredients: [IngredientType],
                     withOptionalIngredients optionalIngredients: [IngredientType]) {
        var optionalIngredientTuples: [(type: IngredientType, probability: Double)] = []

        for ingredientType in optionalIngredients {
            let optionalIngredientTuple = (type: ingredientType,
                                           probability: StageConstants.defaultOptionalProbability)
            optionalIngredientTuples.append(optionalIngredientTuple)
        }

        self.init(withCompulsoryIngredients: compulsoryIngredients, withOptionalIngredients: optionalIngredientTuples)
    }

    convenience init(withIngredients ingredients: [IngredientType]) {
        let optionalIngredients: [(type: IngredientType, probability: Double)] = []

        self.init(withCompulsoryIngredients: ingredients, withOptionalIngredients: optionalIngredients)
    }
}
