//
//  Plate.swift
//  GooreatRestaurant
//
//  Created by Samuel Henry Kurniawan on 14/3/19.
//  Copyright © 2019 CS3217. All rights reserved.
//

import UIKit
import SpriteKit

class Plate: MobileItem, Codable {

    private(set) var food = Food()
    private(set) var listOfIngredients: [Ingredient] = []

    private let positionings = [CGPoint(x: -30, y: 20),
                                CGPoint(x: 0, y: 20),
                                CGPoint(x: 30, y: 20),
                                CGPoint(x: -30, y: 50),
                                CGPoint(x: 0, y: 50),
                                CGPoint(x: 30 , y: 50)]

    init(inPosition position: CGPoint, withSize size: CGSize = StageConstants.plateSize) {
        let plate = SKTexture(imageNamed: "Plate")
        plate.filteringMode = .nearest

        super.init(inPosition: position, withSize: size, withTexture: plate, withName: "Plate")

        self.name = StageConstants.plateName
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setPhysicsBody() {
        super.setPhysicsBody()
        self.physicsBody?.categoryBitMask = StageConstants.plateCategory
    }

    override func ableToInteract(withItem item: Item?) -> Bool {

        let willTake = (item == nil)
        let willAddIngredient = item is Ingredient

        return willTake || willAddIngredient
    }

    override func interact(withItem item: Item?) -> Item? {
        guard ableToInteract(withItem: item) == true else {
            return item
        }

        let willTake = (item == nil)
        let willAddIngredient = item is Ingredient

        if willTake {

            return self

        } else if willAddIngredient {
            guard let ingredient = item as? Ingredient else {
                return nil
            }

            addIngredients(ingredient)

            return nil
        }

        return nil
    }

    func addIngredients(_ ingredient: Ingredient) {
        food.addIngredients(ingredient)
        addIngredientImage(inIngredient: ingredient)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case food
        case position
        case listOfIngredients
    }

    required convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let food = try values.decode(Food.self, forKey: .food)
        let position = try values.decode(CGPoint.self, forKey: .position)
        let listOfIngredients = try values.decode([Ingredient].self, forKey: .listOfIngredients)
        let id = try values.decode(String.self, forKey: .id)

        self.init(inPosition: position)
        self.id = id
        self.food = food
        
        for ingredient in listOfIngredients { self.addIngredientImage(inIngredient: ingredient) }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(food, forKey: .food)
        try container.encode(position, forKey: .position)
        try container.encode(listOfIngredients, forKey: .listOfIngredients)
        try container.encode(id, forKey: .id)
    }

    func addIngredientImage(inIngredient: Ingredient) {
        listOfIngredients.append(inIngredient)

        var ingredientsAtlas = SKTextureAtlas.init()
        let processedCount = inIngredient.processed.count

        if (processedCount == 1) {
            if (inIngredient.processed[processedCount - 1] == CookingType.baking) {
                ingredientsAtlas = SKTextureAtlas(named: "BakedIngredients")
            } else if (inIngredient.processed[processedCount - 1] == CookingType.chopping) {
                ingredientsAtlas = SKTextureAtlas(named: "SlicedIngredients")
            }
        } else if (processedCount > 1){
             ingredientsAtlas = SKTextureAtlas(named: "BakedSlicedIngredients")
        } else {
            ingredientsAtlas = SKTextureAtlas(named: "Ingredients")
        }

        var texture: SKTexture = SKTexture.init()
        texture = ingredientsAtlas.textureNamed(inIngredient.type.rawValue)

        let ingredient = SKSpriteNode(texture: texture)
        ingredient.size = CGSize(width: 30, height: 30)

        //repositioning
        if (listOfIngredients.count <= 6) {
            ingredient.position = positionings[listOfIngredients.count - 1]
        }

        self.addChild(ingredient)
    }
}
