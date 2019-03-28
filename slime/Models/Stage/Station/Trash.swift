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

    override init(inPosition position: CGPoint, withSize size: CGSize = StageConstants.stationSize) {
        super.init(inPosition: position, withSize: size)
        self.color = .blue
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func ableToProcess(_ item: SKSpriteNode?) -> Bool {
        if item == nil {
            return false
        }
        return true
    }

    override func process(_ item: SKSpriteNode?) -> SKSpriteNode? {
        guard ableToProcess(item) == true else {
            return item
        }

        item?.removeFromParent()
        return nil
    }

}
