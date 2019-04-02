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
        let table = SKSpriteNode(imageNamed: "table")
        super.init(inPosition: position, withSize: size)
        table.size = size
        self.physicsBody = SKPhysicsBody(texture: table.texture!, size: table.size)
        self.addChild(table)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var item: SKNode? {
        return children.first
    }

    override func ableToProcess(_ item: SKSpriteNode?) -> Bool {

        let willTake = (item == nil && self.item != nil)
        let willPut = (item != nil && self.item == nil)
        let willAddIngredient = (item is Ingredient && self.item is Plate)

        if willTake || willPut || willAddIngredient {
            return true
        }
        return false
    }

    override func process(_ item: SKSpriteNode?) -> SKSpriteNode? {
        guard ableToProcess(item) == true else {
            return item
        }

        let willTake = (item == nil && self.item != nil)
        let willPut = (item != nil && self.item == nil)
        let willAddIngredient = (item is Ingredient && self.item is Plate)

        if willPut {

            guard let itemToPut = item else {
                return item
            }

            itemToPut.removeFromParent()
            itemToPut.position = CGPoint(x: 0.0, y: 0.5 * (itemToPut.size.height + self.size.height))
            addChild(itemToPut)
            return nil

        } else if willTake {

            guard let itemToTake = self.item as? SKSpriteNode else {
                return nil
            }

            itemToTake.removeFromParent()
            return itemToTake

        } else if willAddIngredient {

            guard let plate = self.item as? Plate else {
                return item
            }

            guard let ingredient = item as? Ingredient else {
                return item
            }

            plate.food.addIngredients(ingredient)
            return nil
        }

        return item

    }

}
