//
//  PlateContainer.swift
//  slime
//
//  Created by Samuel Henry Kurniawan on 27/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import SpriteKit

class PlateStorage: SKSpriteNode {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(inPosition position: CGPoint, withSize size: CGSize = StageConstants.storageSize) {
        super.init(texture: nil, color: .yellow, size: size)
        self.name = StageConstants.plateStorageName
        self.position = position
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = StageConstants.storageCategory
        self.physicsBody?.collisionBitMask = StageConstants.wallCategoryCollision
    }

    func takePlate() -> Plate {
        return Plate(inPosition: self.position)
    }
}
