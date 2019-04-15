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

    // Table can process in multiple different conditions
    // 1. When we want to take item from the table
    //      Requirement: item given is nil and the table own an item
    //      Return: The item on the table
    // 2. When we want to put item on the table
    //      Requirement: item given is an non-nil and the table doesnt own any item
    //      Return: nil
    // 3. When we want to put an ingredient to the plate in the table
    //      Requirement: item given is an ingredient and the table own a plate
    //      Return: nil
    // 4. When we want to put an ingredient on the table to the plate
    //      Requirement: item given is a plate and the table own an ingredient
    //      Return: return back the plate after the ingredient is put into the food on the plate

    override func ableToInteract(withItem item: Item?) -> Bool {

        let willTake = (item == nil && self.itemInside != nil)
        let willPut = (item != nil && self.itemInside == nil)
        let willAddIngredient = (item is Ingredient && self.itemInside is Plate)
        let willTakeIngredientToPlate = (item is Plate && self.itemInside is Ingredient)

        return willTake || willPut || willAddIngredient || willTakeIngredientToPlate
    }

    override func interact(withItem item: Item?) -> Item? {
        guard ableToInteract(withItem: item) == true else {
            return item
        }

        let willTake = (item == nil && self.itemInside != nil)
        let willPut = (item != nil && self.itemInside == nil)
        let willAddIngredient = (item is Ingredient && self.itemInside is Plate)
        let willTakeIngredientToPlate = (item is Plate && self.itemInside is Ingredient)

        // Condition 1
        if willPut {

            guard let itemToPut = item else {
                return item
            }

            self.addItem(itemToPut)
            AudioMaster.instance.playSFX(name: "pickup")
            return nil

        // Condition 2
        } else if willTake {

            guard let itemToTake = self.itemInside as? Item else {
                return nil
            }

            self.removeItem()
            AudioMaster.instance.playSFX(name: "pickup")
            return itemToTake

        // Condition 3
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

        // Condition 4
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
            AudioMaster.instance.playSFX(name: "pickup")
            return plate
        }
        
        return item

    }

}
