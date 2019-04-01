//
//  Ingredient.swift
//  GooreatRestaurant
//
//  Created by Samuel Henry Kurniawan on 14/3/19.
//  Copyright © 2019 CS3217. All rights reserved.
//

import UIKit
import SpriteKit

class Ingredient: SKSpriteNode {
    var type: IngredientType
    var processed: CookingType = .notProcessed

    init(type: IngredientType,
         size: CGSize = StageConstants.ingredientSize,
         inPosition position: CGPoint = CGPoint.zero) {

        self.type = type
        super.init(texture: nil, color: .red, size: size)
        self.name = StageConstants.ingredientName
        self.position = position
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.categoryBitMask = StageConstants.ingredientCategory
        self.physicsBody?.collisionBitMask = StageConstants.wallCategoryCollision
    }

    func cook(by method: CookingType) {
        if self.processed != .notProcessed && self.processed != method {
            self.ruin()
            return
        }
        self.processed = method
    }

    func ruin() {
        self.type = .junk
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}