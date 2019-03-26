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
        room.name = "room"
        self.addChild(room)
    }

    func addSlime(inPosition position: CGPoint, withSize size: CGSize = StageConstants.slimeSize) {
        let slime = Slime(inPosition: position, withSize: size)
        slime.name = "slime"
        self.addChild(slime)
    }

    func addIngredients(type: StageConstants.IngredientType,
                        inPosition position: CGPoint,
                        withSize size: CGSize = StageConstants.ingredientSize) {
        let ingredient = Ingredient(type: type, size: size, inLocation: position)
        ingredient.name = "ingredient"
        self.addChild(ingredient)
    }

    func addCooker(type: StageConstants.CookingType,
                   inPosition position: CGPoint,
                   withSize size: CGSize = StageConstants.cookerSize) {
        let cooker = CookingEquipment(type: type, size: size, inLocation: position)
        cooker.name = "cooker"
        self.addChild(cooker)
    }

    func addPlate(inPosition position: CGPoint,
                  withSize size: CGSize = StageConstants.plateSize) {
        let plate = Plate(inPosition: position, withSize: size)
        plate.name = "plate"
        self.addChild(plate)
    }

    func addWalls(inLevel levelName: String) {
        var coordArray: [String] = []
        var gameAreaCoord: [CGPoint] = []
//        var unaccessibleAreaCoord: [CGPoint] = []
        guard let path = Bundle.main.path(forResource: "LevelDesign", ofType: "plist")  else {
            print("Error loading path")
            return
        }
//
//        //Level 1
        let contents = NSDictionary(contentsOfFile: path)
        coordArray = contents?.object(forKey: levelName) as! [String]
        for item in coordArray {
            gameAreaCoord.append(NSCoder.cgPoint(for: item))
        }

        let spaceshipBorder = SKNode()
        spaceshipBorder.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        let ground = SKShapeNode(points: &gameAreaCoord, count: gameAreaCoord.count)
        spaceshipBorder.physicsBody = SKPhysicsBody(edgeLoopFrom: ground.path!)
        spaceshipBorder.physicsBody?.categoryBitMask = StageConstants.wallCategoryCollision
        spaceshipBorder.physicsBody?.isDynamic = false
        self.addChild(spaceshipBorder)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("initiation using storyboard is not implemented yet.")
    }
}
