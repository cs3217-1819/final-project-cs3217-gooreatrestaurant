//
//  Trash.swift
//  slime
//
//  Created by Samuel Henry Kurniawan on 28/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import SpriteKit

class Trash: Station {

    // Construct a trash
    override init(inPosition position: CGPoint, withSize size: CGSize) {

        let trashBin = SKSpriteNode(imageNamed: "trashbin")
        trashBin.size = StageConstants.stationSize

        super.init(inPosition: position, withSize: trashBin.size)

        self.texture = trashBin.texture

        self.physicsBody = SKPhysicsBody(texture: trashBin.texture!, size: self.size)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = StageConstants.stationCategory
        self.physicsBody?.contactTestBitMask = StageConstants.slimeCategory
        self.physicsBody?.collisionBitMask = StageConstants.wallCategoryCollision
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Trash can only be used when there is an item given to the trash
    override func ableToProcess(_ item: SKSpriteNode?) -> Bool {
        if item == nil {
            return false
        }
        return true
    }

    // Trash process an item by discarding the item given to the trash
    override func process(_ item: SKSpriteNode?) -> SKSpriteNode? {
        guard ableToProcess(item) == true else {
            return item
        }

        item?.removeFromParent()
        return nil
    }

}
