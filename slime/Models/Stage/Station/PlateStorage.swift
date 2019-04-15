//
//  PlateContainer.swift
//  slime
//
//  Created by Samuel Henry Kurniawan on 27/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import SpriteKit

class PlateStorage: Station {

    // PlateStorage acts as "plate producer"
    // Requirements: There is no item given to the station (this station does not accept any item)
    // Returns: A plate

    override func ableToProcess(_ item: SKSpriteNode?) -> Bool {
        if item == nil {
            return true
        }
        return false
    }

    override func process(_ item: SKSpriteNode?) -> SKSpriteNode? {
        guard ableToProcess(item) == true else {
            return nil
        }
        return Plate(inPosition: self.position)
    }
}
