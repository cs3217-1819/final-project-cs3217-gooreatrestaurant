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

    func generateLevel(inLevel levelName: String) {
        if let levelDesignURL = Bundle.main.url(forResource: levelName, withExtension: "plist") {
            do {
                let data = try? Data(contentsOf: levelDesignURL)
                let decoder = PropertyListDecoder()
                let value = try decoder.decode(SerializableGameData.self, from: data!)
                addRoom()
                addSlime(inPosition: value.slimeInitPos)
                addWall(inCoord: value.border)
                addWall(inCoord: value.blockedArea)
                addLadder(inPositions: value.ladder)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func addRoom() {
        let spaceshipBody = SKTexture(imageNamed: "Area")
        spaceshipBody.filteringMode = .nearest // shorter form for SKTextureFilteringMode.Nearest
        let room = SKSpriteNode(texture: spaceshipBody)
        room.position = CGPoint(x: 0, y: 0)
        room.setScale(0.4)
        room.zPosition = 1
        room.name = StageConstants.roomName
        self.addChild(room)
    }

    func addSlime(inPosition position: String) {
        let slime = Slime(inPosition: NSCoder.cgPoint(for: position))
        self.addChild(slime)
    }

    func addWall(inCoord coordinates: [String]) {
        var gameAreaCoord: [CGPoint] = []
        for item in coordinates {
            gameAreaCoord.append(NSCoder.cgPoint(for: item))
        }
        let wallBorder = SKNode()
        wallBorder.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        let ground = SKShapeNode(points: &gameAreaCoord, count: gameAreaCoord.count)
        wallBorder.physicsBody = SKPhysicsBody(edgeLoopFrom: ground.path!)
        wallBorder.physicsBody?.categoryBitMask = StageConstants.wallCategoryCollision
        wallBorder.physicsBody?.isDynamic = false
        self.addChild(wallBorder)
    }

    func addLadder(inPositions positions: [String]) {
        for position in positions {
            let ladder = Ladder(inPosition: NSCoder.cgPoint(for: position))
            self.addChild(ladder)
        }
    }

    func addChoppingEquipment(inPositions positions: [String]) {
        for position in positions {
            let equipment = ChoppingEquipment(inPosition: NSCoder.cgPoint(for: position))
            self.addChild(equipment)
        }
    }

    func addFryingEquipment(inPositions positions: [String]) {
        for position in positions {
            let equipment = FryingEquipment(inPosition: NSCoder.cgPoint(for: position))
            self.addChild(equipment)
        }
    }

    func addOven(inPositions positions: [String]) {
        for position in positions {
            let oven = Oven(inPosition: NSCoder.cgPoint(for: position))
            self.addChild(oven)
        }
    }

    func addIngredientStorage(withDetails details: [(type: String, position: String)]) {
        for ingredientData in details {
            guard let ingredientEnum = Int(ingredientData.type) else {
                continue
            }

            guard let ingredientType = IngredientType(rawValue: ingredientEnum) else {
                continue
            }
            let storage = IngredientStorage(ofType: ingredientType, inPosition: NSCoder.cgPoint(for: ingredientData.position))
            self.addChild(storage)
        }
    }

    func addPlateStorage(inPositions positions: [String]) {
        for position in positions {
            let storage = PlateStorage(inPosition: NSCoder.cgPoint(for: position))
            self.addChild(storage)
        }
    }

    func addStoreFront(inPosition position: String) {
        let storefront = StoreFront(inPosition: NSCoder.cgPoint(for: position))
        self.addChild(storefront)
    }

    func addTable(inPositions positions: [String]) {
        for position in positions {
            let table = Table(inPosition: NSCoder.cgPoint(for: position))
            self.addChild(table)
        }
    }

    func addTrashBin(inPositions positions: [String]) {
        for position in positions {
            let trashBin = Trash(inPosition: NSCoder.cgPoint(for: position))
            self.addChild(trashBin)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("initiation using storyboard is not implemented yet.")
    }
}
