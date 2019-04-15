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

    // The cooking type of this equipment
    private let cookingType: CookingType

    // Timer that fire once in a while to automatically process the ingredients
    private var automaticProcessingTimer = Timer()

    // Allowed ingredients to be processed into this cooking equipment
    private var ingredientsAllowed: Set<IngredientType> = []

    // Construct a cooking equipment
    init(type: CookingType,
         inPosition position: CGPoint,
         withSize size: CGSize,
         canProcessIngredients ingredients: [IngredientType] = []) {

        self.cookingType = type

        for ingredient in ingredients {
            _ = ingredientsAllowed.insert(ingredient)
        }

        super.init(inPosition: position, withSize: size)
        self.automaticProcessingTimer = Timer.scheduledTimer(timeInterval: StageConstants.cookingTimerInterval,
                                                             target: self,
                                                             selector: #selector(automaticProcessing),
                                                             userInfo: nil,
                                                             repeats: true)
    }
    
    // Function to be overridden, called when the food starts processing
    func onStartProcessing() {
        
    }
    
    // Function to be overridden, called when the food gets progressed.
    func onProgressProcessing() {
        
    }
    
    // Function to be overridden, called when the food finishes processing
    func onEndProcessing() {
        
    }

    // To check whether the ingredient inside this equipment is ready to take (finished processing)
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

    // Put ingredient inside this cooking equipment
    // Parameters: the ingredient that will be added
    func putIngredient(_ ingredient: Ingredient) {
        guard itemInside == nil else {
            return
        }

        self.addItem(ingredient)
    }

    // Take out the item inside this equipment
    // return the item as SKSpriteNode
    func takeitemInside() -> Item? {
        guard canTakeIngredient == true else {
            return nil
        }

        guard let toTake = itemInside as? Item else {
            return nil
        }
        self.removeItem()
        return toTake
    }

    override func ableToInteract(withItem item: Item?) -> Bool {

        let willPut = (item is Ingredient && self.itemInside == nil)
        let willProcess = (item == nil && self.itemInside != nil)
        let willTakeIngredientToPlate = self.itemInside?.ableToInteract(withItem: item) ?? false

        return willPut || willProcess || willTakeIngredientToPlate
    }

    override func interact(withItem item: Item?) -> Item? {
        guard ableToInteract(withItem: item) == true else {
            return nil
        }

        let willPut = (item is Ingredient && self.itemInside == nil)
        let willProcess = (item == nil && self.itemInside != nil)
        let willTakeIngredientToPlate = (item is Plate && self.itemInside is Ingredient)

        if willPut {
            guard let ingredientToPut = item as? Ingredient else {
                return item
            }
            onStartProcessing()
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

            return toAdd.interact(withItem: item)
        }
        return nil
    }

    // To process ingredient with a particular progress value
    // If the ingredient is allowed to be processed by this equipment, will cook the ingredients. Else, will ruin it
    func continueProcessing(withProgress progress: Double) {
        guard let ingredient = itemInside as? Ingredient else {
            return
        }

        // If not, then all non allowed ingredients put (even not process) here will become junk
        // because of automatic processing of 0.0
        if progress == 0.0 {
            return
        }
        
        onProgressProcessing()

        if ingredientsAllowed.contains(ingredient.type) {
            ingredient.cook(by: self.cookingType, withProgress: progress)
            
            if canTakeIngredient {
                onEndProcessing()
            }
        } else {
            ingredient.ruin()
        }
    }

    // Automatic processing, called by timer
    @objc func automaticProcessing() {
        continueProcessing(withProgress: 0.0)
    }

    // Manual processing, called from 
    func manualProcessing() {
        continueProcessing(withProgress: 100.0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
