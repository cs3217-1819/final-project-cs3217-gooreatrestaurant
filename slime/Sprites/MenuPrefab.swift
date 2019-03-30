//
//  MenuPrefab.swift
//  slime
//
//  Created by Developer on 30/3/19.
//  Copyright © 2019 nus.cs3217.a0143378y. All rights reserved.
//

import Foundation
import SpriteKit

class MenuPrefab : SKSpriteNode {
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        print("A")
        self.position = CGPoint.zero
        self.zPosition = 5
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func temp() {
        print("TEST")
    }
}
