//
//  Station.swift
//  slime
//
//  Created by Samuel Henry Kurniawan on 28/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import SpriteKit

class Station: SKSpriteNode {

    // ID of the station, to refer to it in the networking database
    var id: String?

    // Construct a station
    // The station will be able to have contact with slime object, but not colliding with it
    // Parameters:
    //      - position: the position of the center of mass of the station relative to the parent
    //      - size: the size of the station, default value is located in the constants
    init(inPosition position: CGPoint, withSize size: CGSize = StageConstants.stationSize) {

        // default texture of station is using table's texture
        let table = SKSpriteNode(imageNamed: "table")
        table.size = size
        super.init(texture: table.texture, color: .clear, size: size)
        self.name = StageConstants.stationName
        self.position = position
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

    // How to make different stations:
    // - Subclass this class
    // - Override ableToProcess and process func with the subclass specifications, explained below

    // Check whether the item is able to be processed by this station
    // Parameters:
    //      - item: the item that is queried, can be nil, where there is no item passed to this station
    // Return value:
    //        true if the the item is able to be processed by this station, false otherwise
    func ableToProcess(_ item: SKSpriteNode?) -> Bool {
        return false
    }

    // Process an item
    // Parameter:
    //      - item: the item that will be processed, can be nil when there is no item passed to this station
    // Return value:
    //      Optional SKSpriteNode, the item that has been processed (or nil if the processing does not produce anything)
    func process(_ item: SKSpriteNode?) -> SKSpriteNode? {
        return nil
    }
}
