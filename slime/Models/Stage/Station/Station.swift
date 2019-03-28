//
//  Station.swift
//  slime
//
//  Created by Samuel Henry Kurniawan on 28/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import SpriteKit

class Station: SKSpriteNode {

    init(inPosition position: CGPoint, withSize size: CGSize) {
        super.init(texture: nil, color: .yellow, size: size)
        self.name = StageConstants.stationName
        self.position = position
        self.zPosition = StageConstants.stationZPos

        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = StageConstants.stationCategory
        self.physicsBody?.collisionBitMask = StageConstants.wallCategoryCollision
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func ableToProcess(_ item: SKSpriteNode?) -> Bool {
        return false
    }

    func process(_ item: SKSpriteNode?) -> SKSpriteNode? {
        return nil
    }
}
