//
//  Table.swift
//  slime
//
//  Created by Samuel Henry Kurniawan on 28/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import SpriteKit

class Table: Station {

    override func ableToProcess(_ item: SKSpriteNode?) -> Bool {

        let willTake = (item == nil && self.itemInside != nil)
        let willPut = (item != nil && self.itemInside == nil)
        let willAddIngredient = (item is Ingredient && self.itemInside is Plate)
        let willTakeIngredientToPlate = (item is Plate && self.itemInside is Ingredient)

        return willTake || willPut || willAddIngredient || willTakeIngredientToPlate
    }

    override func process(_ item: SKSpriteNode?) -> SKSpriteNode? {
        guard ableToProcess(item) == true else {
            return item
        }

        let willTake = (item == nil && self.itemInside != nil)
        let willPut = (item != nil && self.itemInside == nil)
        let willAddIngredient = (item is Ingredient && self.itemInside is Plate)
        let willTakeIngredientToPlate = (item is Plate && self.itemInside is Ingredient)

        if willPut {

            guard let itemToPut = item else {
                return item
            }

            self.addItem(itemToPut)
            return nil

        } else if willTake {

            guard let itemToTake = self.itemInside as? SKSpriteNode else {
                return nil
            }

            self.removeItem()
            return itemToTake

        } else if willAddIngredient {

            guard let plate = self.itemInside as? Plate else {
                return item
            }

            guard let ingredient = item as? Ingredient else {
                return item
            }

            plate.food.addIngredients(ingredient)
            plate.addIngredientImage(inIngredient: ingredient)
            return nil

        } else if willTakeIngredientToPlate {

            guard let plate = item as? Plate else {
                return item
            }

            guard let ingredient = self.itemInside as? Ingredient else {
                return item
            }

            ingredient.removeFromParent()
            plate.food.addIngredients(ingredient)
            plate.addIngredientImage(inIngredient: ingredient)
            return plate
        }

        return item

    }

}
