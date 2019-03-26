//
//  IngredientContainer.swift
//  slime
//
//  Created by Samuel Henry Kurniawan on 27/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import SpriteKit

class IngredientContainer: SKSpriteNode {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let type: StageConstants.IngredientType

    init(ofType type: StageConstants.IngredientType,
         inPosition position: CGPoint,
         withSize size: CGSize = StageConstants.storageSize) {

        self.type = type
        super.init(texture: nil, color: .purple, size: size)
        self.name = StageConstants.ingredientContainerName
        self.position = position
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = StageConstants.storageCategory
        self.physicsBody?.collisionBitMask = StageConstants.wallCategoryCollision
    }

    func takeIngredient() -> Ingredient {
        return Ingredient(type: self.type, inPosition: self.position)
    }
}
