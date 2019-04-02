//
//  Recipe.swift
//  slime
//
//  Created by Samuel Henry Kurniawan on 28/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class Recipe: NSObject {
    private(set) var recipeName: String
    private(set) var ingredientsNeeded: [IngredientData:Int] = [:]
    private let originalCompulsoryIngredients: [IngredientData]
    private let originalOptionalIngredients: [(item: IngredientData, probability: Double)]

    init(inRecipeName nameOfRecipe: String, withCompulsoryIngredients compulsoryIngredients: [IngredientData],
         withOptionalIngredients optionalIngredients: [(item: IngredientData, probability: Double)]) {

        self.recipeName = nameOfRecipe
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

    convenience init(inRecipeName nameOfRecipe: String, withCompulsoryIngredients compulsoryIngredients: [IngredientData],
                     withOptionalIngredients optionalIngredients: [IngredientData]) {
        var optionalIngredientTuples: [(item: IngredientData, probability: Double)] = []

        for ingredient in optionalIngredients {
            let optionalIngredientTuple = (item: ingredient,
                                           probability: StageConstants.defaultOptionalProbability)
            optionalIngredientTuples.append(optionalIngredientTuple)
        }

        self.init(inRecipeName: nameOfRecipe, withCompulsoryIngredients: compulsoryIngredients, withOptionalIngredients: optionalIngredientTuples)
    }

    convenience init(inRecipeName nameOfRecipe: String, withIngredients ingredients: [IngredientData]) {
        let optionalIngredients: [(item: IngredientData, probability: Double)] = []

        self.init(inRecipeName: nameOfRecipe, withCompulsoryIngredients: ingredients, withOptionalIngredients: optionalIngredients)
    }

    func regenerateRecipe() -> Recipe {
        return Recipe(inRecipeName: recipeName, withCompulsoryIngredients: originalCompulsoryIngredients,
                      withOptionalIngredients: originalOptionalIngredients)
    }
}
