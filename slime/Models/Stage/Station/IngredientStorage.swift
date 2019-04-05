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

    let type: IngredientType

    init(ofType type: IngredientType,
         inPosition position: CGPoint,
         withSize size: CGSize = StageConstants.stationSize) {
        self.type = type
        super.init(inPosition: position, withSize: size)
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
        return Ingredient(type: self.type, inPosition: self.position)
    }
}
