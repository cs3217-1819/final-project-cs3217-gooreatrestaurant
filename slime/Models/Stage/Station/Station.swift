//
//  Station.swift
//  slime
//
//  Created by Samuel Henry Kurniawan on 28/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import SpriteKit

class Station: Item {

    // Item inside the station, if the station allow item storing
    var itemInside: SKNode? {
        return children.first
    }

    // Construct a station
    // The station will be able to have contact with slime object, but not colliding with it
    // Parameters:
    //      - position: the position of the center of mass of the station relative to the parent
    //      - size: the size of the station, default value is located in the constants
    init(inPosition position: CGPoint, withSize size: CGSize = StageConstants.stationSize) {

        // default texture of station is using table's texture
        let table = SKSpriteNode(imageNamed: "table")
        table.size = size

        super.init(inPosition: position, withSize: size, withTexture: table.texture)

        self.name = StageConstants.stationName
        self.zPosition = StageConstants.stationZPos

        self.physicsBody = SKPhysicsBody(texture: table.texture!, size: table.size)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = StageConstants.stationCategory
        self.physicsBody?.contactTestBitMask = StageConstants.slimeCategory
        self.physicsBody?.collisionBitMask = StageConstants.wallCategoryCollision
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /* 
     * How to make different stations:
     * - Subclass this class
     * - Override ableToInteract and interact func with the subclass specifications, explained below
    **/

    // Add an item to the station
    // If the station contained an item, do not do anything
    // Parameters:
    //      - item: the item to be added
    func addItem(_ item: MobileItem) {
        guard itemInside == nil else {
            return
        }

        item.taken(by: self)
    }

    // Remove the item that this station held (and for future expansion, this will remove all items)
    func removeItem() {
        self.removeAllChildren()
    }
}
