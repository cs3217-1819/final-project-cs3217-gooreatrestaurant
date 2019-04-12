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

    private var canTakeIngredient: Bool {
        guard let ingredient = self.itemInside as? Ingredient else {
            return false
        }

        // if ingredient is ruined or finished processing, can take
        // RI: after finished processing, will put the this type as the last proccessed
        if ingredient.type == .junk || ingredient.processed.last == self.cookingType {
            return true
        }

        return false
    }

    override func ableToProcess(_ item: SKSpriteNode?) -> Bool {

        let willPut = (item is Ingredient && self.itemInside == nil)
        let willProcess = (item == nil && self.itemInside != nil)
        let willTakeIngredientToPlate = (item is Plate && self.itemInside is Ingredient)

        return willPut || willProcess || willTakeIngredientToPlate
    }

    override func process(_ item: SKSpriteNode?) -> SKSpriteNode? {
        guard ableToProcess(item) == true else {
            return nil
        }

        let willPut = (item is Ingredient && self.itemInside == nil)
        let willProcess = (item == nil && self.itemInside != nil)
        let willTakeIngredientToPlate = (item is Plate && self.itemInside is Ingredient)

        if willPut {
            guard let ingredientToPut = item as? Ingredient else {
                return item
            }
            putIngredient(ingredientToPut)
            return nil

        } else if willProcess {
            guard let toTake = takeitemInside() else {
                manualProcessing()
                return nil
            }
            return toTake

        } else if willTakeIngredientToPlate {
            guard let toAdd = takeitemInside() as? Ingredient else {
                return nil
            }

            guard let plate = item as? Plate else {
                return nil
            }

            plate.food.addIngredients(toAdd)
            return plate
        }
        return nil
    }

    func continueProcessing(withProgress progress: Double) {
        guard let ingredient = itemInside as? Ingredient else {
            return
        }

        // If not, then all non allowed ingredients put (even not process) here will become junk
        // because of automatic processing of 0.0
        if progress == 0.0 {
            return
        }

        if ingredientsAllowed.contains(ingredient.type) {
            ingredient.cook(by: self.cookingType, withProgress: progress)
        } else {
            ingredient.ruin()
        }
    }

    func automaticProcessing() {
        continueProcessing(withProgress: 0.0)
    }

    func manualProcessing() {
        continueProcessing(withProgress: 100.0)
    }

    func putIngredient(_ ingredient: Ingredient) {
        guard itemInside == nil else {
            return
        }

        self.addItem(ingredient)
    }

    func takeitemInside() -> SKSpriteNode? {
        guard canTakeIngredient == true else {
            return nil
        }

        guard let toTake = itemInside as? SKSpriteNode else {
            return nil
        }
        self.removeItem()
        return toTake
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
