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
        let plate = SKTexture(imageNamed: "Plate")
        plate.filteringMode = .nearest
        super.init(texture: plate, color: .clear, size: size)
        self.name = StageConstants.plateName
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.categoryBitMask = StageConstants.plateCategory
        self.physicsBody?.collisionBitMask = StageConstants.wallCategoryCollision
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
