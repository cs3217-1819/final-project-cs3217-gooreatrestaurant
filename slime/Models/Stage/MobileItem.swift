//
//  MobileItem.swift
//  slime
//
//  Created by Samuel Henry Kurniawan on 15/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import SpriteKit

class MobileItem: Item {

    override init(inPosition position: CGPoint, withSize size: CGSize, withTexture texture: SKTexture?) {
        super.init(inPosition: position, withSize: size, withTexture: texture)

        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.collisionBitMask = StageConstants.wallCategoryCollision
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
