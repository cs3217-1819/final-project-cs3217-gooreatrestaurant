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

    var ingredientInProcess: SKNode? {
        return children.first
    }

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

        let willPut = (item is Ingredient && self.ingredientInProcess == nil)
        let willProcess = (item == nil && self.ingredientInProcess != nil)

        return willPut || willProcess
    }

    override func process(_ item: SKSpriteNode?) -> SKSpriteNode? {
        guard ableToProcess(item) == true else {
            return nil
        }

        let willPut = (item is Ingredient && self.ingredientInProcess == nil)
        let willProcess = (item == nil && self.ingredientInProcess != nil)

        if willPut {
            guard let ingredientToPut = item as? Ingredient else {
                return item
            }
            putIngredient(ingredientToPut)
            return nil

        } else if willProcess {
            guard let ingredient = self.ingredientInProcess as? Ingredient else {
                return nil
            }
            if ingredient.type == .junk || ingredient.processed.last == self.cookingType {
                guard let toTake = takeIngredientInProcess() else {
                    return nil
                }
                return toTake
            } else {
                manualProcessing()
                return nil
            }
        }
        return nil
    }

    func continueProcessing(withProgress progress: Int) {
        guard let ingredient = ingredientInProcess as? Ingredient else {
            return
        }

        if ingredientsAllowed.contains(ingredient.type) {
            ingredient.cook(by: self.cookingType, withProgress: progress)
        } else {
            ingredient.ruin()
        }
    }

    func automaticProcessing() {
        continueProcessing(withProgress: 0)
    }

    func manualProcessing() {
        continueProcessing(withProgress: 100)
    }

    func putIngredient(_ ingredient: Ingredient) {
        guard ingredientInProcess == nil else {
            return
        }

        ingredient.removeFromParent()
        ingredient.position = CGPoint(x: 0.0, y: 0.5 * (ingredient.size.height + self.size.height))
        addChild(ingredient)
    }

    func takeIngredientInProcess() -> SKSpriteNode? {
        guard let toTake = ingredientInProcess as? SKSpriteNode else {
            return nil
        }
        toTake.removeFromParent()
        return toTake
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
