//
//  CookingEquipment.swift
//  GooreatRestaurant
//
//  Created by Samuel Henry Kurniawan on 20/3/19.
//  Copyright © 2019 CS3217. All rights reserved.
//

import UIKit
import SpriteKit

class CookingEquipment: Station {

    let cookingType: CookingType
    var ingredientsAllowed: Set<IngredientType> = []

    init(type: CookingType,
         inPosition position: CGPoint,
         withSize size: CGSize,
         canProcessIngredients ingredients: [IngredientType] = []) {

        self.cookingType = type

        for ingredient in ingredients {
            _ = ingredientsAllowed.insert(ingredient)
        }

        super.init(inPosition: position, withSize: size)
        self.color = .green
    }

    override func ableToProcess(_ item: SKSpriteNode?) -> Bool {
        if item is Ingredient {
            return true
        }
        return false
    }

    override func process(_ item: SKSpriteNode?) -> SKSpriteNode? {
        guard ableToProcess(item) == true else {
            return nil
        }

        guard let ingredient = item as? Ingredient else {
            return nil
        }

        if ingredientsAllowed.contains(ingredient.type) {
//            ingredient.cook(by: self.cookingType)
            ingredient.cook(by: self.cookingType, withProgress: 20)
        } else {
            ingredient.ruin()
        }

        return ingredient
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
