//
//  Spaceship.swift
//  GooreatRestaurant
//
//  Created by Samuel Henry Kurniawan on 14/3/19.
//  Copyright © 2019 CS3217. All rights reserved.
//

import UIKit
import SpriteKit

class Spaceship: SKSpriteNode {

    // position is in the center
    init(inPosition position: CGPoint, withSize size: CGSize) {
        let spaceshipBody = SKTexture(imageNamed: "SpaceshipMAIN")
        spaceshipBody.filteringMode = .nearest
        super.init(texture: spaceshipBody, color: .clear, size: size)
        self.position = CGPoint.zero
        self.zPosition = 0
    }

    func addRoom() {
        let spaceshipBody = SKTexture(imageNamed: "Area")
        spaceshipBody.filteringMode = .nearest // shorter form for SKTextureFilteringMode.Nearest
        let room = SKSpriteNode(texture: spaceshipBody)
        room.position = CGPoint(x: 0, y: 0)
        room.size = StageConstants.gameAreaSize
        room.zPosition = 1
        room.name = StageConstants.roomName
        self.addChild(room)
    }

    func addSlime(inPosition position: String) {
        let slime = Slime(inPosition: NSCoder.cgPoint(for: position))
        self.addChild(slime)
    }

    func addWall(inCoord coordinates: [[String]]) {
        for item in coordinates {
            var gameAreaCoord: [CGPoint] = []
            for point in item {
                gameAreaCoord.append(NSCoder.cgPoint(for: point))
            }
            let wallBorder = SKNode()
            wallBorder.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            let ground = SKShapeNode(points: &gameAreaCoord, count: gameAreaCoord.count)
            wallBorder.physicsBody = SKPhysicsBody(edgeChainFrom: ground.path!)
            //        wallBorder.physicsBody = SKPhysicsBody(edgeLoopFrom: ground.path!)
            wallBorder.physicsBody?.categoryBitMask = StageConstants.wallCategoryCollision
            wallBorder.physicsBody?.isDynamic = false
            self.addChild(wallBorder)
        }
    }

    func addLadder(inPositions positions: [String]) {
        for position in positions {
            let ladder = Ladder(inPosition: NSCoder.cgPoint(for: position))
            self.addChild(ladder)
        }
    }

    func addChoppingEquipment(inPositions positions: [String], record dict: inout [String : Station]) {
        for (index, position) in positions.enumerated() {
            let equipment = ChoppingEquipment(inPosition: NSCoder.cgPoint(for: position))
            equipment.id = "choppingEquipment-\(index)"
            self.addChild(equipment)
            guard let id = equipment.id else { continue }
            dict.updateValue(equipment, forKey: id)
        }
    }

    func addFryingEquipment(inPositions positions: [String], record dict: inout [String : Station]) {
        for (index, position) in positions.enumerated() {
            let equipment = FryingEquipment(inPosition: NSCoder.cgPoint(for: position))
            equipment.id = "fryingEquipment-\(index)"
            self.addChild(equipment)
            guard let id = equipment.id else { continue }
            dict.updateValue(equipment, forKey: id)
        }
    }

    func addOven(inPositions positions: [String], record dict: inout [String : Station]) {
        for (index, position) in positions.enumerated() {
            let oven = Oven(inPosition: NSCoder.cgPoint(for: position))
            oven.id = "oven-\(index)"
            self.addChild(oven)
            guard let id = oven.id else { continue }
            dict.updateValue(oven, forKey: id)
        }
    }

    func addIngredientStorage(withDetails details: [(type: String, position: String)]) {
        for (index, ingredientData) in details.enumerated() {
            guard let ingredientType = IngredientType(rawValue: ingredientData.type) else {
                continue
            }
            let storage = IngredientStorage(ofType: ingredientType, inPosition: NSCoder.cgPoint(for: ingredientData.position))
            storage.id = "ingredientStorage-\(index)"
            self.addChild(storage)
        }
    }

    func addPlateStorage(inPositions positions: [String]) {
        for (index, position) in positions.enumerated() {
            let storage = PlateStorage(inPosition: NSCoder.cgPoint(for: position))
            storage.id = "plateStorage-\(index)"
            self.addChild(storage)
        }
    }

    func addStoreFront(inPosition position: String) {
        let storefront = StoreFront(inPosition: NSCoder.cgPoint(for: position))
        self.addChild(storefront)
    }

    func addTable(inPositions positions: [String], record dict: inout [String : Station]) {
        for (index, position) in positions.enumerated() {
            let table = Table(inPosition: NSCoder.cgPoint(for: position))
            table.id = "table-\(index)"
            self.addChild(table)
            guard let id = table.id else { continue }
            dict.updateValue(table, forKey: id)
        }
    }

    func addTrashBin(inPositions positions: [String]) {
        for position in positions {
            let trashBin = Trash(inPosition: NSCoder.cgPoint(for: position), withSize: CGSize(width: 100, height: 100))
            trashBin.id = "trashBin-\(index)"
            self.addChild(trashBin)
        }
    }

    func setAutomaticCooking() {
        self.enumerateChildNodes(withName: StageConstants.stationName) {
            node, _ in

            guard let cookingEquipment = node as? CookingEquipment else {
                return
            }
            cookingEquipment.automaticProcessing()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("initiation using storyboard is not implemented yet.")
    }
}
