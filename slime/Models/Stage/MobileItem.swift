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

        setPhysicsBody()

        let timeValue = Date().timeIntervalSinceReferenceDate
        let timeString = Int(timeValue * 1000)
        let uid = GameAuth.currentUser?.uid ?? "someRandomString"

        self.id = "\(uid)-\(name)-\(timeString)"

        self.zPosition = StageConstants.mobileItemZPos
    }

    func setPhysicsBody() {
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.collisionBitMask = StageConstants.wallCategoryCollision
        self.physicsBody?.allowsRotation = false
    }

    func unsetPhysicsBody() {
        self.physicsBody = nil
    }

    func taken(by owner: SKSpriteNode) {
        self.removeFromParent()
        self.position.x = 0.0
        self.position.y = 0.4 * (self.size.height + owner.size.height)
        unsetPhysicsBody()

        owner.addChild(self)
    }

    func dropped(by owner: SKSpriteNode) {
        self.removeFromParent()
        self.position.x = owner.position.x
        self.position.y = owner.position.y
        setPhysicsBody()

        owner.parent?.addChild(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
