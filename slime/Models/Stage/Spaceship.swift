//
//  Spaceship.swift
//  GooreatRestaurant
//
//  Created by Samuel Henry Kurniawan on 14/3/19.
//  Copyright © 2019 CS3217. All rights reserved.
//

import UIKit
import SpriteKit

/*
 Spaceship is for generating anything is needed for the level/stage
 This is for initializing, such as rendering and positionings
 */
class Spaceship: SKSpriteNode {
    var levelName = ""
    let SpaceshipAtlas = SKTextureAtlas(named: "Spaceship")

    // position is in the center
    init(inPosition position: CGPoint, withSize size: CGSize) {
        super.init(texture: nil, color: .clear, size: size)
        self.position = CGPoint.zero
        self.zPosition = 0
    }

    func addRoom() {
        var texture = SpaceshipAtlas.textureNamed("")
        switch self.levelName {
        case "Level1":
            texture = SpaceshipAtlas.textureNamed("Area-1")
        case "Level2":
            texture = SpaceshipAtlas.textureNamed("Area-2")
        case "Multiplayer-Level1":
            texture = SpaceshipAtlas.textureNamed("MP-Area-1")
        default:
            texture = SpaceshipAtlas.textureNamed("Area-1")
        }
        texture.filteringMode = .nearest
        let room = SKSpriteNode(texture: texture)
        room.size = self.levelName != "Multiplayer-Level1" ? StageConstants.gameAreaSize : CGSize(width: 1600, height: 800)
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
        for (index, position) in positions.enumerated() {
            let trashBin = Trash(inPosition: NSCoder.cgPoint(for: position), withSize: StageConstants.trashBinSize)
            trashBin.id = "trashBin-\(index)"
            self.addChild(trashBin)
        }
    }

    func setLevelName(inString: String) {
        self.levelName = inString
        var texture = SpaceshipAtlas.textureNamed("")
        switch self.levelName {
        case "Level1":
            texture = SpaceshipAtlas.textureNamed("Spaceship-1")
        case "Level2":
            texture = SpaceshipAtlas.textureNamed("Spaceship-2")
        case "Multiplayer-Level1":
            texture = SpaceshipAtlas.textureNamed("MP-Spaceship-1")
        default:
            texture = SpaceshipAtlas.textureNamed("Spaceship-1")
        }
        texture.filteringMode = .nearest
        self.size = self.levelName != "Multiplayer-Level1" ? StageConstants.gameAreaSize : CGSize(width: 1600, height: 800)
        self.texture = texture
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("initiation using storyboard is not implemented yet.")
    }
}
