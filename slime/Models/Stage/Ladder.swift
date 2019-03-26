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
        self.position = position
        self.zPosition = 2
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    func buildLadder(position: CGPoint) {
//        let ladder = SKTexture(imageNamed: "Ladder")
//        ladder.filteringMode = .nearest // shorter form for SKTextureFilteringMode.Nearest
//        spaceship = SKSpriteNode(texture: ladder)
//        spaceship.position = position
//        spaceship.setScale(0.1)
//        spaceship.zPosition = 2
//        addChild(spaceship)
//
//        let ladderBody = SKNode()
//        ladderBody.position = position
//        ladderBody.name = "LadderBody"
//        ladderBody.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 10, height: 45))
//        ladderBody.physicsBody?.categoryBitMask = interactableObjCategory
//        ladderBody.physicsBody?.isDynamic = false
//        self.addChild(ladderBody)
//    }
}
