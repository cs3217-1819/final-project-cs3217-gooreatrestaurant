//
//  Ladder.swift
//  GooreatRestaurant
//
//  Created by Samuel Henry Kurniawan on 14/3/19.
//  Copyright © 2019 CS3217. All rights reserved.
//

import UIKit
import SpriteKit

class Ladder: SKSpriteNode {
    init(inPosition position: CGPoint) {
        let ladder = SKTexture(imageNamed: "Ladder")
        ladder.filteringMode = .nearest
        super.init(texture: ladder, color: .clear, size: StageConstants.ladderSize)
        self.name = StageConstants.ladderName
        self.position = position
        self.zPosition = 2

        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 10, height: 45))
        self.physicsBody?.categoryBitMask = StageConstants.ladderCategory
        self.physicsBody?.isDynamic = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
