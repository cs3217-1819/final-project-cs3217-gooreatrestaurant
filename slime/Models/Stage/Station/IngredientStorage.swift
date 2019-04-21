//
//  IngredientStorage.swift
//  slime
//
//  Created by Samuel Henry Kurniawan on 27/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import SpriteKit

class IngredientStorage: Station {

    // The type of ingredient given
    private let type: IngredientType

    init(ofType type: IngredientType,
         inPosition position: CGPoint,
         withSize size: CGSize = StageConstants.stationSize) {
        self.type = type
        super.init(inPosition: position, withSize: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // IngredientStorage act as "ingrdient producer"
    // Requirements: item given to this station is nil (this station does not accept any item)
    // Return: The ingredient with a specific type

    override func ableToInteract(withItem item: Item?) -> Bool {
        if item == nil {
            return true
        }
        return false
    }

    override func interact(withItem item: Item?) -> Item? {
        guard ableToInteract(withItem: item) == true else {
            return nil
        }
        return Ingredient(type: self.type, inPosition: self.position)
    }
}
