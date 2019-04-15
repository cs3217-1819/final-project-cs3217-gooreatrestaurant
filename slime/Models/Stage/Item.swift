//
//  Item.swift
//  slime
//
//  Created by Samuel Henry Kurniawan on 15/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import SpriteKit

class Item: SKSpriteNode {

    var id: String?

    init(inPosition position: CGPoint, withSize size: CGSize, withTexture texture: SKTexture?) {
        super.init(texture: texture, color: .clear, size: size)
        self.position = position
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Check whether the item is able to be processed by this station
    // Parameters:
    //      - item: the item that is queried, can be nil, where there is no item passed to this station
    // Return value:
    //        true if the the item is able to be processed by this station, false otherwise
    func ableToInteract(withItem item: Item?) -> Bool {
        return false
    }

    // Process an item
    // Parameters:
    //      - item: the item that will be processed, can be nil when there is no item passed to this station
    // Return value:
    //      Optional SKSpriteNode, the item that has been processed (or nil if the processing does not produce anything)
    func interact(withItem item: Item?) -> Item? {
        return nil
    }
}
