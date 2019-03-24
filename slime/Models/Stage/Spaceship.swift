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

    var rooms: [Room] = []
    var slimes: [Slime] = []
    var cookingEquipments: [CookingEquipment] = []
    var ingredientsOnFloor: [Ingredient] = []
    var platesOnFloor: [Plate] = []

    // position is in the center
    init(inPosition position: CGPoint, withSize size: CGSize) {
        let spaceshipBody = SKTexture(imageNamed: "SpaceshipMAIN")
        spaceshipBody.filteringMode = .nearest
        super.init(texture: spaceshipBody, color: .clear, size: size)
        self.position = position
        self.zPosition = 0
    }


    func addRoom(inPosition position: CGPoint, withSize size: CGSize) {
        let room = Room(withPosition: position, andSize: size)
        rooms.append(room)
        self.addChild(room)
    }

    func addSlime(inPosition position: CGPoint, withSize size: CGSize = StageConstants.slimeSize) {
        let slime = Slime(inPosition: position, withSize: size, andParents: self)
        slimes.append(slime)
        self.addChild(slime)
    }

    func addIngredients(type: StageConstants.IngredientType,
                        inPosition position: CGPoint,
                        withSize size: CGSize = StageConstants.ingredientSize) {
        let ingredient = Ingredient(type: type, size: size, inLocation: position)
        ingredientsOnFloor.append(ingredient)
        self.addChild(ingredient)
    }

    func addCooker(type: StageConstants.CookingType,
                   inPosition position: CGPoint,
                   withSize size: CGSize = StageConstants.cookerSize) {
        let cooker = CookingEquipment(type: type, size: size, inLocation: position)
        cookingEquipments.append(cooker)
        self.addChild(cooker)
    }

    func addPlate(inPosition position: CGPoint,
                  withSize size: CGSize = StageConstants.plateSize) {
        let plate = Plate(inPosition: position, withSize: size)
        platesOnFloor.append(plate)
        self.addChild(plate)
    }

    func addWalls(withPoints points: [CGPoint]) {
        var pointsList = points
        let shape = SKShapeNode(points: &pointsList, count: points.count)
        let wall = SKNode()

        // 0, 0 is in the spaceship's center
        wall.position = CGPoint(x: 0, y: 0)
        wall.physicsBody = SKPhysicsBody(edgeLoopFrom: shape.path!)
        wall.physicsBody?.categoryBitMask = StageConstants.wallCategoryCollision
        wall.physicsBody?.isDynamic = false
        self.addChild(wall)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("initiation using storyboard is not implemented yet.")
    }
}
