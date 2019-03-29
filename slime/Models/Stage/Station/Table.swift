//
//  Table.swift
//  slime
//
//  Created by Samuel Henry Kurniawan on 28/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import SpriteKit

class Table: Station {

    override init(inPosition position: CGPoint, withSize size: CGSize = StageConstants.stationSize) {
        super.init(inPosition: position, withSize: size)
        self.color = .yellow
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var item: SKNode? {
        return children.first
    }

    override func ableToProcess(_ item: SKSpriteNode?) -> Bool {
        if (item == nil && self.item != nil) || (item != nil && self.item == nil) {
            return true
        }
        return false
    }

    override func process(_ item: SKSpriteNode?) -> SKSpriteNode? {
        guard ableToProcess(item) == true else {
            return item
        }

        if self.item == nil {

            guard let itemToPut = item else {
                return item
            }

            itemToPut.removeFromParent()
            itemToPut.position = CGPoint(x: 0.0, y: 0.5 * (itemToPut.size.height + self.size.height))
            addChild(itemToPut)
            return nil

        } else {

            guard let itemToTake = self.item else {
                return nil
            }

            itemToTake.removeFromParent()
            return itemToTake

        }

    }

}
