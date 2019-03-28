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

    let ingredientType: StageConstants.IngredientType

    init(ofType type: StageConstants.IngredientType,
         inPosition position: CGPoint,
         withSize size: CGSize = StageConstants.stationSize) {

        self.ingredientType = type
        super.init(inPosition: position, withSize: size)
        self.color = .purple
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func ableToProcess(_ item: SKSpriteNode?) -> Bool {
        if item == nil {
            return true
        }
        return false
    }

    override func process(_ item: SKSpriteNode?) -> SKSpriteNode? {
        guard ableToProcess(item) == true else {
            return nil
        }
        return Ingredient(type: self.ingredientType, inPosition: self.position)
    }

    // TO DO remove this
    func takeIngredient() -> Ingredient {
        return Ingredient(type: self.ingredientType, inPosition: self.position)
    }
}
