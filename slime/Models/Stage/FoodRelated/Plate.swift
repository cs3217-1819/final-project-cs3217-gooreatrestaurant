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

    private var foodImage: SKSpriteNode? = nil
    private(set) var food = Food()
    private(set) var listOfIngredients: [Ingredient] = []

    private let positionings = [CGPoint(x: -30, y: 20),
                                CGPoint(x: 0, y: 20),
                                CGPoint(x: 30, y: 20),
                                CGPoint(x: -30, y: 50),
                                CGPoint(x: 0, y: 50),
                                CGPoint(x: 30 , y: 50)]

    let kitchenwareAtlas = SKTextureAtlas(named: "Kitchenware")

    init(inPosition position: CGPoint, withSize size: CGSize = StageConstants.plateSize) {
        let plate = kitchenwareAtlas.textureNamed("Plate")
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
        case position
        case listOfIngredients
    }

    required convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let position = try values.decode(CGPoint.self, forKey: .position)
        let listOfIngredients = try values.decode([Ingredient].self, forKey: .listOfIngredients)
        let id = try values.decode(String.self, forKey: .id)

        self.init(inPosition: position)
        self.id = id
        
        for ingredient in listOfIngredients { self.addIngredients(ingredient) }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(position, forKey: .position)
        try container.encode(listOfIngredients, forKey: .listOfIngredients)
        try container.encode(id, forKey: .id)
    }

    func addIngredientImage(inIngredient: Ingredient) {
        let ingredient = inIngredient.deepCopy() as? Ingredient ?? inIngredient
        listOfIngredients.append(ingredient)

        if foodImage == nil {
            ingredient.isHidden = false
        }

        ingredient.size = CGSize(width: 30, height: 30)
        ingredient.taken(by: self)

        //repositioning
        if (listOfIngredients.count <= 6) {
            ingredient.position = positionings[listOfIngredients.count - 1]
        }

    }

    private func recheckImages(ofFoodName foodName: String?) {

        if let name = foodName {

            for ingredient in listOfIngredients {
                ingredient.isHidden = true
            }

            let ingredientsAtlas = SKTextureAtlas(named: "Recipes")
            var texture: SKTexture = SKTexture.init()
            texture = ingredientsAtlas.textureNamed(name)

            let image = SKSpriteNode(texture: texture)
            foodImage = image
            self.addChild(image)
            foodImage?.position = CGPoint(x: 0, y: 30)
            foodImage?.size = CGSize(width: 40, height: 40)

        } else {

            foodImage?.removeFromParent()
            foodImage = nil

            for ingredient in listOfIngredients {
                ingredient.isHidden = false
            }
        }
    }

    override func deepCopy() -> MobileItem {
        let selfCopy = Plate(inPosition: self.position)
        selfCopy.id = self.id

        for ingredient in self.listOfIngredients {
            selfCopy.addIngredients(ingredient)
        }

        return selfCopy
    }
}
