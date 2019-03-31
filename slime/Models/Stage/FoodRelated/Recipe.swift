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
    private let originalCompulsoryIngredients: [Ingredient]
    private let originalOptionalIngredients: [(item: Ingredient, probability: Double)]

    init(withCompulsoryIngredients compulsoryIngredients: [Ingredient],
         withOptionalIngredients optionalIngredients: [(item: Ingredient, probability: Double)]) {

        self.originalCompulsoryIngredients = compulsoryIngredients
        self.originalOptionalIngredients = optionalIngredients

        var ingredientsRequirement = compulsoryIngredients

        for ingredientData in optionalIngredients {
            let ingredient = ingredientData.item
            let probability = ingredientData.probability

            guard drand48() < probability else {
                continue
            }

            ingredientsRequirement.append(ingredient)
        }

        for ingredient in ingredientsRequirement {
            if ingredientsNeeded[ingredient] == nil {
                ingredientsNeeded[ingredient] = 0
            }

            ingredientsNeeded[ingredient]? += 1
        }
    }

    convenience init(withCompulsoryIngredients compulsoryIngredients: [Ingredient],
                     withOptionalIngredients optionalIngredients: [Ingredient]) {
        var optionalIngredientTuples: [(item: Ingredient, probability: Double)] = []

        for ingredient in optionalIngredients {
            let optionalIngredientTuple = (item: ingredient,
                                           probability: StageConstants.defaultOptionalProbability)
            optionalIngredientTuples.append(optionalIngredientTuple)
        }

        self.init(withCompulsoryIngredients: compulsoryIngredients, withOptionalIngredients: optionalIngredientTuples)
    }

    convenience init(withIngredients ingredients: [Ingredient]) {
        let optionalIngredients: [(item: Ingredient, probability: Double)] = []

        self.init(withCompulsoryIngredients: ingredients, withOptionalIngredients: optionalIngredients)
    }

    func regenerateRecipe() -> Recipe {
        return Recipe(withCompulsoryIngredients: originalCompulsoryIngredients,
                      withOptionalIngredients: originalOptionalIngredients)
    }
}