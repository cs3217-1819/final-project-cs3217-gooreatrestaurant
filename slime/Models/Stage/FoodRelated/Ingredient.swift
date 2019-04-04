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
    var processed: [CookingType] = []

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
        if self.processed != [] && self.processed.last != method {
            self.ruin()
            return
        }
        self.processed.append(method)
    }

    func ruin() {
        self.type = .junk
    }

    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.type)
        hasher.combine(self.processed)
        return hasher.finalize()
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Ingredient else {
            return false
        }

        return self.type == other.type && self.processed == other.processed
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}