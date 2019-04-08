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
    private(set) var ingredientsNeeded: [Ingredient: Int] = [:]
    private let originalCompulsoryIngredients: [Ingredient]
    private let originalOptionalIngredients: [(item: Ingredient, probability: Double)]

    init(inRecipeName nameOfRecipe: String, withCompulsoryIngredients compulsoryIngredients: [Ingredient],
         withOptionalIngredients optionalIngredients: [(item: Ingredient, probability: Double)]) {

        self.recipeName = nameOfRecipe
        self.originalCompulsoryIngredients = compulsoryIngredients
        self.originalOptionalIngredients = optionalIngredients

        var ingredientsRequirement = compulsoryIngredients

        for ingredient in optionalIngredients {
            let item = ingredient.item
            let probability = ingredient.probability

            guard drand48() < probability else {
                continue
            }

            ingredientsRequirement.append(item)
        }

        for ingredient in ingredientsRequirement {
            if ingredientsNeeded[ingredient] == nil {
                ingredientsNeeded[ingredient] = 0
            }
            ingredientsNeeded[ingredient]? += 1
        }
    }

    convenience init(inRecipeName nameOfRecipe: String, withCompulsoryIngredients compulsoryIngredients: [Ingredient],
                     withOptionalIngredients optionalIngredients: [Ingredient]) {
        var optionalIngredientTuples: [(item: Ingredient, probability: Double)] = []

        for ingredient in optionalIngredients {
            let optionalIngredientTuple = (item: ingredient,
                                           probability: StageConstants.defaultOptionalProbability)
            optionalIngredientTuples.append(optionalIngredientTuple)
        }

        self.init(inRecipeName: nameOfRecipe, withCompulsoryIngredients: compulsoryIngredients, withOptionalIngredients: optionalIngredientTuples)
    }

    convenience init(inRecipeName nameOfRecipe: String, withIngredients ingredients: [Ingredient]) {
        let optionalIngredients: [(item: Ingredient, probability: Double)] = []

        self.init(inRecipeName: nameOfRecipe, withCompulsoryIngredients: ingredients, withOptionalIngredients: optionalIngredients)
    }

    // To generate the same recipe but with the optional ingredients probability re-rolled again
    func regenerateRecipe() -> Recipe {
        return Recipe(inRecipeName: recipeName, withCompulsoryIngredients: originalCompulsoryIngredients,
                      withOptionalIngredients: originalOptionalIngredients)
    }
}
