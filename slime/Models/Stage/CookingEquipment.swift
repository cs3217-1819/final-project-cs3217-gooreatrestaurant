//
//  CookingEquipment.swift
//  GooreatRestaurant
//
//  Created by Samuel Henry Kurniawan on 20/3/19.
//  Copyright © 2019 CS3217. All rights reserved.
//

import UIKit
import SpriteKit

class CookingEquipment: SKSpriteNode {
    let type: StageConstants.CookingType

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(type: StageConstants.CookingType, size: CGSize, inLocation location: CGPoint) {
        self.type = type
        super.init(texture: nil, color: .green, size: size)
        self.position = location
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = StageConstants.cookerCategory
        self.physicsBody?.collisionBitMask = StageConstants.wallCategoryCollision
    }
}
