//
//  StoreFront.swift
//  slime
//
//  Created by Samuel Henry Kurniawan on 28/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import SpriteKit

class StoreFront: Station {

    // Storefront works by taking a plate and submit the food inside to the orderqueue
    // Requirement: item given to this station is a Plate
    // Return: nil, plate given to this station is served

    override func ableToInteract(withItem item: Item?) -> Bool {
        guard item is Plate else {
            return false
        }
        return true
    }

    override func interact(withItem item: Item?) -> Item? {
        guard ableToInteract(withItem: item) == true else {
            return item
        }

        guard let plate = item as? Plate else {
            return item
        }

        guard let stage = self.scene as? Stage else {
            return item
        }
        
        let successfullyServed = stage.serve(plate)
        if successfullyServed {
            AudioMaster.instance.playSFX(name: "kaching")
        } else {
            AudioMaster.instance.playSFX(name: "bad-order")
        }

        return nil
    }
}
