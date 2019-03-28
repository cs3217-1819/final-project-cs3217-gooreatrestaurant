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
        room.setScale(0.4)
        room.zPosition = 1
        room.name = StageConstants.roomName
        self.addChild(room)
    }

    func addSlime(inPosition position: CGPoint, withSize size: CGSize = StageConstants.slimeSize) {
        let slime = Slime(inPosition: position, withSize: size)
        self.addChild(slime)
    }

    func addIngredients(type: StageConstants.IngredientType,
                        inPosition position: CGPoint,
                        withSize size: CGSize = StageConstants.ingredientSize) {
        let ingredient = Ingredient(type: type, size: size, inPosition: position)
        self.addChild(ingredient)
    }

    func addCooker(type: StageConstants.CookingType,
                   inPosition position: CGPoint,
                   withSize size: CGSize = StageConstants.cookerSize) {
        let cooker = CookingEquipment(type: type, size: size, inLocation: position)
        self.addChild(cooker)
    }

    func addPlate(inPosition position: CGPoint,
                  withSize size: CGSize = StageConstants.plateSize) {
        let plate = Plate(inPosition: position, withSize: size)
        self.addChild(plate)
    }

    func addPlayingArea(inLevel levelName: String) {
        //Generating the walls
        guard let path = Bundle.main.path(forResource: "LevelDesign", ofType: "plist")  else {
            print("Error loading path")
            return
        }
        let dictionary = NSDictionary(contentsOfFile: path)
        let temp = dictionary?.value(forKey: levelName) as! [[String]]

        for item in temp {
            addWall(inCoord: item)
        }
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

    func addLadder(inPosition position: CGPoint) {
        let ladder = Ladder(inPosition: position)
        self.addChild(ladder)
    }

    func addPlateStorage(inPosition position: CGPoint) {
        let plateStorage = PlateStorage(inPosition: position)
        self.addChild(plateStorage)
    }

    func addIngredientStorage(ofType type: StageConstants.IngredientType, inPosition position: CGPoint) {
        let ingredientStorage = IngredientStorage(ofType: type, inPosition: position)
        self.addChild(ingredientStorage)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("initiation using storyboard is not implemented yet.")
    }
}
