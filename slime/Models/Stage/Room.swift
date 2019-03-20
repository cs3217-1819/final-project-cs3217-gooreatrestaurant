//
//  Room.swift
//  GooreatRestaurant
//
//  Created by Samuel Henry Kurniawan on 14/3/19.
//  Copyright © 2019 CS3217. All rights reserved.
//

import UIKit
import SpriteKit

// this coordinates is relative to the spaceship's (parent's)
class Room: SKSpriteNode {

    // position is the center of the node
    init(withPosition position: CGPoint, andSize size: CGSize) {
        super.init(texture: nil, color: .white, size: size)
        self.position = position
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("initiation using storyboard is not implemented yet.")
    }
}
