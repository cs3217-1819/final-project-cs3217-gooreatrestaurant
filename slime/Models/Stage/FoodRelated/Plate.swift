//
//  Plate.swift
//  GooreatRestaurant
//
//  Created by Samuel Henry Kurniawan on 14/3/19.
//  Copyright © 2019 CS3217. All rights reserved.
//

import UIKit
import SpriteKit

class Plate: SKSpriteNode, Codable {
    var food = Food()
    var listOfIngredients: [Ingredient] = []

    let positionings = [CGPoint(x: -15, y: 10),
                        CGPoint(x: 0, y: 10),
                        CGPoint(x: 15, y: 10),
                        CGPoint(x: -15, y: 25),
                        CGPoint(x: 0, y: 25),
                        CGPoint(x: 15, y: 25)]

    init(inPosition position: CGPoint, withSize size: CGSize = StageConstants.plateSize) {
        let plate = SKTexture(imageNamed: "Plate")
        plate.filteringMode = .nearest
        super.init(texture: plate, color: .clear, size: size)
        self.name = StageConstants.plateName
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.categoryBitMask = StageConstants.plateCategory
        self.physicsBody?.collisionBitMask = StageConstants.wallCategoryCollision
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addIngredients(_ ingredient: Ingredient) {
        food.addIngredients(ingredient)
        addIngredientImage(inIngredient: ingredient)
    }

    enum CodingKeys: String, CodingKey {
        case food
        case position
        case listOfIngredients
    }

    required convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let food = try values.decode(Food.self, forKey: .food)
        let position = try values.decode(CGPoint.self, forKey: .position)
        let listOfIngredients = try values.decode([Ingredient].self, forKey: .listOfIngredients)
        
        self.init(inPosition: position)
        self.food = food
        
        for ingredient in listOfIngredients { self.addIngredientImage(inIngredient: ingredient) }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(food, forKey: .food)
        try container.encode(position, forKey: .position)
        try container.encode(listOfIngredients, forKey: .listOfIngredients)
    }

    func addIngredientImage(inIngredient: Ingredient) {
        listOfIngredients.append(inIngredient)

        var ingredientsAtlas = SKTextureAtlas.init()

        if (inIngredient.processed.count != 0) {
            ingredientsAtlas = SKTextureAtlas(named: "ProcessedIngredients")
        } else {
            ingredientsAtlas = SKTextureAtlas(named: "Ingredients")
        }

        var texture: SKTexture = SKTexture.init()
        texture = ingredientsAtlas.textureNamed(inIngredient.type.rawValue)

        let ingredient = SKSpriteNode(texture: texture)
        ingredient.size = CGSize(width: 15, height: 15)

        //repositioning
        if (listOfIngredients.count <= 6) {
            ingredient.position = positionings[listOfIngredients.count - 1]
        }

        self.addChild(ingredient)
    }
}
