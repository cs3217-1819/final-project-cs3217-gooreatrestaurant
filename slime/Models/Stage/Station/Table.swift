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

    // Table can process in multiple different conditions
    // 1. When we want to take item from the table
    //      Requirement: item given is nil and the table own an item
    //      Return: The item on the table
    // 2. When we want to put item on the table
    //      Requirement: item given is an non-nil and the table doesnt own any item
    //      Return: nil
    // 3. When we want to put an ingredient to the plate in the table
    //      Requirement: item given is an ingredient and the table own a plate
    //      Return: nil
    // 4. When we want to put an ingredient on the table to the plate
    //      Requirement: item given is a plate and the table own an ingredient
    //      Return: return back the plate after the ingredient is put into the food on the plate

    override func ableToInteract(withItem item: Item?) -> Bool {

        let willPut = (item != nil && self.itemInside == nil)
        let willInteract = self.itemInside?.ableToInteract(withItem: item) ?? false

        return willPut || willInteract
    }

    override func interact(withItem item: Item?) -> Item? {
        guard ableToInteract(withItem: item) == true else {
            return item
        }
        let willPut = (item != nil && self.itemInside == nil)
        let willInteract = self.itemInside?.ableToInteract(withItem: item) ?? false
        // Condition 1
        if willPut {
            guard let itemToPut = item as? MobileItem else {
                return item
            }
            self.addItem(itemToPut)
            return nil
        // Condition 2 and 3 and 4
        } else if willInteract {
            return self.itemInside?.interact(withItem: item)
        }
        return item
    }
}
