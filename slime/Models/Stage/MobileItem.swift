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

    init(inPosition position: CGPoint, withSize size: CGSize, withTexture texture: SKTexture?, withName name: String) {
        super.init(inPosition: position, withSize: size, withTexture: texture)

        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.collisionBitMask = StageConstants.wallCategoryCollision

        let timeValue = Date().timeIntervalSinceReferenceDate
        let timeString = String(format: "%.5f", timeValue)
        let user = GameAuth.currentUser?.uid ?? "someRandomString"

        self.id = name + "-" + user + "-" + timeString
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
