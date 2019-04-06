//
//  GameOverPrefab.swift
//  slime
//
//  Created by Developer on 6/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverPrefab : SKSpriteNode {
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        let base = SKTexture(imageNamed: "Border")
        base.filteringMode = .nearest

        super.init(texture: base, color: color, size: size)
        self.position = CGPoint.zero
        self.zPosition = 10
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
