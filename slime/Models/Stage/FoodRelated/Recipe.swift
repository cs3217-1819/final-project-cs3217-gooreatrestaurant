//
//  Recipe.swift
//  slime
//
//  Created by Samuel Henry Kurniawan on 28/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class Recipe: NSObject, Codable {
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

    enum CodingKeys: String, CodingKey {
        case recipeName
        case ingredientsNeeded
        case compulsoryIngredients
        case optionalIngredientsIngredient
        case optionalIngredientsProbability
    }

    required convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let recipeName = try values.decode(String.self, forKey: .recipeName)
        let ingredientsNeeded = try values.decode([Ingredient:Int].self, forKey: .ingredientsNeeded)
        let compulsoryIngredients = try values.decode([Ingredient].self, forKey: .compulsoryIngredients)
        let optionalIngredientsIngredient = try values.decode([Ingredient].self, forKey: .optionalIngredientsIngredient)
        let optionalIngredientsProbability = try values.decode([Double].self, forKey: .optionalIngredientsProbability)

        var optionalIngredients: [(item: Ingredient, probability: Double)] = []

        let noOfElement = min(optionalIngredientsProbability.count, optionalIngredientsIngredient.count)

        if noOfElement > 0 {
            for index in 0...(noOfElement-1) {
                let ingredient = optionalIngredientsIngredient[index]
                let probability = optionalIngredientsProbability[index]
                optionalIngredients.append((item: ingredient, probability: probability))
            }
        }

        self.init(inRecipeName: recipeName,
                  withCompulsoryIngredients: compulsoryIngredients,
                  withOptionalIngredients: optionalIngredients)
        self.ingredientsNeeded = ingredientsNeeded
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(recipeName, forKey: .recipeName)
        try container.encode(ingredientsNeeded, forKey: .ingredientsNeeded)
        try container.encode(originalCompulsoryIngredients, forKey: .compulsoryIngredients)

        let optionalIngredientsIngredient = originalOptionalIngredients.map { $0.item }
        let optionalIngredientsProbability = originalOptionalIngredients.map { $0.probability }

        try container.encode(optionalIngredientsIngredient, forKey: .optionalIngredientsIngredient)
        try container.encode(optionalIngredientsProbability, forKey: .optionalIngredientsProbability)
    }
}
