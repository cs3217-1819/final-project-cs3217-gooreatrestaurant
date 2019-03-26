//
//  Plate.swift
//  GooreatRestaurant
//
//  Created by Samuel Henry Kurniawan on 14/3/19.
//  Copyright © 2019 CS3217. All rights reserved.
//

import UIKit
import SpriteKit

class Plate: SKSpriteNode {
    let food = Food()

    init(inPosition position: CGPoint, withSize size: CGSize = StageConstants.plateSize) {
        super.init(texture: nil, color: .black, size: size)
        self.name = StageConstants.plateName
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.categoryBitMask = StageConstants.plateCategory
        self.physicsBody?.collisionBitMask = StageConstants.wallCategoryCollision
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Bool here is success / fail
    func putIngredient(_ ingredient: Ingredient) -> Bool {
        return self.food.addIngredient(ingredient)
    }
}
