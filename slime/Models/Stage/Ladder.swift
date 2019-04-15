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
    let kitchenwareAtlas = SKTextureAtlas(named: "Kitchenware")
    init(inPosition position: CGPoint) {
        let ladder = kitchenwareAtlas.textureNamed("Ladder")
        ladder.filteringMode = .nearest
        super.init(texture: ladder, color: .clear, size: StageConstants.ladderSize)
        self.name = StageConstants.ladderName
        self.position = position
        self.zPosition = StageConstants.ladderZPos

        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 20, height: 90))
        self.physicsBody?.categoryBitMask = StageConstants.ladderCategory
        self.physicsBody?.isDynamic = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
