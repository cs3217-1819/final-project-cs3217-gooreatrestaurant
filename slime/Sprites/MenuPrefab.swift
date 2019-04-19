//
//  MenuPrefab.swift
//  slime
//
//  Created by Developer on 30/3/19.
//  Copyright © 2019 nus.cs3217.a0143378y. All rights reserved.
//

import Foundation
import SpriteKit

class MenuPrefab: SKSpriteNode, Codable {
    var randInt: Int
    var recipe: Recipe?
    var blackBar: SKSpriteNode
    var greenBar: SKSpriteNode
    var timer: Timer =  Timer()
    var time: CGFloat = StageConstants.defaultTimeLimitOrder
    var duration: CGFloat = StageConstants.defaultTimeLimitOrder
    let UIAtlas = SKTextureAtlas(named: "UI")
    let positionings = [CGPoint(x: -25, y: -15),
                        CGPoint(x: -5, y: -15),
                        CGPoint(x: 15, y: -15)]

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        let randNum = Int.random(in: 1...4)
        let texture = UIAtlas.textureNamed("Menu-Slimes_" + String(randNum))
        texture.filteringMode = .nearest
        self.randInt = randNum
        self.blackBar = SKSpriteNode(imageNamed: "Black bar")
        self.greenBar = SKSpriteNode(imageNamed: "Green bar")
        super.init(texture: texture, color: color, size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addRecipe(_ recipe: Recipe, inPosition: CGPoint) {
        self.position = inPosition
        self.recipe = recipe
        //Adding image of the main recipe
        let ingredientsAtlas = SKTextureAtlas(named: "Recipes")
        var texture: SKTexture = SKTexture.init()
        texture = ingredientsAtlas.textureNamed(recipe.recipeName)
        let dish = SKSpriteNode(texture: texture)
        dish.position = CGPoint(x: 0, y: 15)
        dish.zPosition = 5
        dish.size = CGSize(width: 45, height: 45)

        for (key, _) in recipe.ingredientsNeeded {
            guard let ingredientCount = recipe.ingredientsNeeded[key] else {
                continue
            }
            for i in 1...ingredientCount {
                let child = addIngredient(withType: key.type.rawValue)
                child.position = positionings[i-1]
                var cookingTypeImg = SKSpriteNode.init()
                if (key.processed.contains(CookingType.baking)) {
                    cookingTypeImg = SKSpriteNode(texture: UIAtlas.textureNamed("Oven-BW"))
                } else if (key.processed.contains(CookingType.frying)) {
                    cookingTypeImg = SKSpriteNode(texture: UIAtlas.textureNamed("Fry-BW"))
                } else if (key.processed.contains(CookingType.chopping)) {
                    cookingTypeImg = SKSpriteNode(texture: UIAtlas.textureNamed("Knife-BW"))
                }
                cookingTypeImg.size = CGSize(width: 15, height: 15)
                cookingTypeImg.position = CGPoint(x: 0, y: -15)
                child.addChild(cookingTypeImg)
                self.addChild(child)
            }
        }

        //Adding the countdown bar
        blackBar.position = StageConstants.blackBarPosOQ
        blackBar.size = StageConstants.blackBarSizeOQ
        greenBar.anchorPoint = StageConstants.greenBarAnchorOQ
        greenBar.position = StageConstants.greenBarPositionOQ
        greenBar.size = StageConstants.greenBarSizeOQ
        blackBar.addChild(greenBar)
        dish.addChild(blackBar)
        self.addChild(dish)

        timer = Timer.scheduledTimer(timeInterval: StageConstants.timerInterval,
                                     target: self,
                                     selector: #selector(countdown),
                                     userInfo: nil,
                                     repeats: true)
    }

    func addIngredient(withType type: String) -> SKSpriteNode {
        let blackCircle = SKSpriteNode(imageNamed: "Black Base Circle")
        blackCircle.position = CGPoint(x: 0, y: -10)
        blackCircle.size = CGSize(width: 20, height: 20)

        //Add the ingredients
        let ingredientsAtlas = SKTextureAtlas(named: "Ingredients")
        var texture: SKTexture = SKTexture.init()
        texture = ingredientsAtlas.textureNamed(type)
        let ingredient = SKSpriteNode(texture: texture)
        ingredient.size = CGSize(width: 15, height: 15)
        blackCircle.addChild(ingredient)

        return blackCircle
    }

    @objc func countdown() {
        if (time > 0.0) {
            time -= CGFloat(1.0)
            self.greenBar.size =  CGSize(width: greenBar.size.width,
                                         height: StageConstants.greenBarSizeOQ.height * time / duration)
        } else {
            timer.invalidate()
            guard let parent = self.parent else {
                return
            }
            guard let orderQueue = parent as? OrderQueue else {
                return
            }

            guard let thisRecipe = recipe else {
                return
            }
            orderQueue.orderTimeOut(ofRecipe: thisRecipe)
        }
    }

    enum CodingKeys: String, CodingKey {
        case randInt
        case recipe
        case time
        case duration
        case position
        case nextTimer
    }

    required convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let randInt = try values.decode(Int.self, forKey: .randInt)
        let recipe = try values.decode(Recipe.self, forKey: .recipe)
        let time = try values.decode(CGFloat.self, forKey: .time)
        let duration = try values.decode(CGFloat.self, forKey: .duration)
        let position = try values.decode(CGPoint.self, forKey: .position)
        let nextTimer = try values.decode(Date.self, forKey: .nextTimer)

        self.init(color: StageConstants.menuPrefabColor, size: StageConstants.menuPrefabSize)
        self.randInt = randInt
        self.texture = SKTexture(imageNamed: "Menu-Slimes_" + String(randInt))
        self.texture?.filteringMode = .nearest
        self.addRecipe(recipe, inPosition: position)
        self.time = time
        self.duration = duration
        self.timer = Timer(fireAt: nextTimer,
                           interval: StageConstants.timerInterval,
                           target: self,
                           selector: #selector(countdown),
                           userInfo: nil,
                           repeats: true)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(randInt, forKey: .randInt)
        try container.encode(recipe, forKey: .recipe)
        try container.encode(time, forKey: .time)
        try container.encode(duration, forKey: .duration)
        try container.encode(position, forKey: .position)
        try container.encode(timer.fireDate, forKey: .nextTimer)
    }
}
