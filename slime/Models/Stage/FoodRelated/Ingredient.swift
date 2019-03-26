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
    var type: StageConstants.IngredientType
    var processed = false

    init(type: StageConstants.IngredientType,
         size: CGSize = StageConstants.ingredientSize,
         inPosition position: CGPoint) {

        self.type = type
        super.init(texture: nil, color: .red, size: size)
        self.name = StageConstants.ingredientName
        self.position = position
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.categoryBitMask = StageConstants.ingredientCategory
        self.physicsBody?.collisionBitMask = StageConstants.wallCategoryCollision
    }

    func cook(using equipment: CookingEquipment) {
        process(by: equipment.type)
        self.color = .gray
    }

    private func process(by method: StageConstants.CookingType) {
        if StageConstants.wayToCook[type] == method {
            processed = true
        } else {
            self.type = .junk
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
