//
//  Plate.swift
//  GooreatRestaurant
//
//  Created by Samuel Henry Kurniawan on 14/3/19.
//  Copyright © 2019 CS3217. All rights reserved.
//

import UIKit
import SpriteKit

class Plate: SKSpriteNode {
    let food = Food()
    var listOfIngredients: [Ingredient] = []

    let positionings = [CGPoint(x: 0, y: 0),
                        CGPoint(x: 100, y: 100)]

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

        self.addChild(ingredient)
    }
}
