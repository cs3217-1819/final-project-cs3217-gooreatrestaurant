//
//  RecipeTemplate.swift
//  slime
//
//  Created by Samuel Henry Kurniawan on 21/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class RecipeTemplate: NSObject, Codable {

    private let compulsoryIngredients: [Ingredient]
    private let optionalIngredients: [(item: Ingredient, probability: Double)]
    private(set) var recipeName: String

    init(withRecipeName name: String,
         withCompulsoryIngredients compulsoryIngredients: [Ingredient],
         withOptionalIngredients optionalIngredients: [(item: Ingredient, probability: Double)]) {

        self.recipeName = name
        self.compulsoryIngredients = compulsoryIngredients
        self.optionalIngredients = optionalIngredients
    }

    func generateRecipe() -> Recipe {
        return Recipe(inRecipeName: recipeName,
                      withCompulsoryIngredients: compulsoryIngredients,
                      withOptionalIngredients: optionalIngredients)
    }

    // To check if the food passed into the arguments is fulfilling any possible recipe generated by this template
    func possibleConsists(of food: Food) -> Bool {
        var ingredients = food.ingredientsList

        // this variable is used to check the number of nonZeroIngredientsRemaining
        // this will increase optimization from O(n**2) to O(n)
        var nonZeroIngredients = ingredients.count

        for ingredient in compulsoryIngredients {
            // if the recipe ingredient is not found in the food, then it is false
            guard ingredients[ingredient] != nil else {
                return false
            }

            ingredients[ingredient]? -= 1
            let remaining = ingredients[ingredient] ?? 0

            // if the food ingredient - recipe ingredient (the same one) less than 0, then it is false
            guard remaining >= 0 else {
                return false
            }

            // if the delta of the ingredients drop to 0, we can reduce the variable value by 1
            // So no need everytime checking how many ingredients have nonzero delta remaining (esp on optional)
            if remaining == 0 {
                nonZeroIngredients -= 1
            }
        }

        if nonZeroIngredients == 0 {
            return true
        }

        for (ingredient, _) in optionalIngredients {
            if ingredients[ingredient] == nil {
                ingredients[ingredient] = 0
            }

            ingredients[ingredient]? -= 1

            let remaining = ingredients[ingredient] ?? 0
            if remaining == 0 {
                nonZeroIngredients -= 1
            }

            // If anytime during the optional the delta hit 0, it is immediately true
            if nonZeroIngredients == 0 {
                return true
            }
        }

        return false
    }

    enum CodingKeys: String, CodingKey {
        case recipeName
        case compulsoryIngredients
        case optionalIngredientsIngredient
        case optionalIngredientsProbability
    }

    required convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let recipeName = try values.decode(String.self, forKey: .recipeName)
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

        self.init(withRecipeName: recipeName,
                  withCompulsoryIngredients: compulsoryIngredients,
                  withOptionalIngredients: optionalIngredients)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(recipeName, forKey: .recipeName)
        try container.encode(compulsoryIngredients, forKey: .compulsoryIngredients)
        try container.encode(optionalIngredients.map{ $0.item }, forKey: .optionalIngredientsIngredient)
        try container.encode(optionalIngredients.map{ $0.probability }, forKey: .optionalIngredientsProbability)
    }
}
