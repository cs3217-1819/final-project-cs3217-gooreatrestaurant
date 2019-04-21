//
//  Recipe.swift
//  slime
//
//  Created by Samuel Henry Kurniawan on 28/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class Recipe: NSObject, Codable {
    private(set) var ingredientsNeeded: [Ingredient: Int] = [:]
    private(set) var recipeName: String

    init(inRecipeName nameOfRecipe: String,
         withCompulsoryIngredients compulsoryIngredients: [Ingredient],
         withOptionalIngredients optionalIngredients: [(item: Ingredient, probability: Double)]) {

        self.recipeName = nameOfRecipe

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

        self.init(inRecipeName: nameOfRecipe,
                  withCompulsoryIngredients: compulsoryIngredients,
                  withOptionalIngredients: optionalIngredientTuples)
    }

    convenience init(inRecipeName nameOfRecipe: String, withIngredients ingredients: [Ingredient]) {
        let optionalIngredients: [(item: Ingredient, probability: Double)] = []

        self.init(inRecipeName: nameOfRecipe,
                  withCompulsoryIngredients: ingredients,
                  withOptionalIngredients: optionalIngredients)
    }

    enum CodingKeys: String, CodingKey {
        case recipeName
        case ingredientsNeeded
    }

    required convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let recipeName = try values.decode(String.self, forKey: .recipeName)
        let ingredientsNeeded = try values.decode([Ingredient:Int].self, forKey: .ingredientsNeeded)

        self.init(inRecipeName: recipeName,
                  withCompulsoryIngredients: [],
                  withOptionalIngredients: [Ingredient]())
        self.ingredientsNeeded = ingredientsNeeded
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(recipeName, forKey: .recipeName)
        try container.encode(ingredientsNeeded, forKey: .ingredientsNeeded)
    }
}
