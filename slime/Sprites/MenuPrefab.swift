//
//  MenuPrefab.swift
//  slime
//
//  Created by Developer on 30/3/19.
//  Copyright © 2019 nus.cs3217.a0143378y. All rights reserved.
//

import Foundation
import SpriteKit

/*
 Menu Prefab is being used for rendering the orders
 The logic for the orders itself is not being handled here as this is purely used for rendering.
 This includes:
 - The recipe image
 - The ingredients images (capped at 3)
 - The amount of time left for the menu
 */
class MenuPrefab: SKSpriteNode, Codable {
    //Variables needed for setting the positioning and sizing
    static let dishSize = CGSize(width: 45, height: 45)
    static let dishPosition = CGPoint(x: 0, y: 15)
    var randInt: Int
    var recipe: Recipe?
    //Black bar and green bar are used for the timer countdown
    var blackBar: SKSpriteNode
    var greenBar: SKSpriteNode
    var timer: Timer =  Timer()
    var time: CGFloat = StageConstants.defaultTimeLimitOrder
    var duration: CGFloat = StageConstants.defaultTimeLimitOrder
    let UIAtlas = SKTextureAtlas(named: "UI")
    //positionings to place the location of the ingredients
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

    //Use for adding the images for the recipe and ingredients
    func addRecipe(_ recipe: Recipe, inPosition: CGPoint) {
        self.position = inPosition
        self.recipe = recipe
        //Adding image of the main recipe
        let ingredientsAtlas = SKTextureAtlas(named: "Recipes")
        var texture: SKTexture = SKTexture.init()
        texture = ingredientsAtlas.textureNamed(recipe.recipeName)

        //initializing recipe image
        let dish = SKSpriteNode(texture: texture)
        dish.position = MenuPrefab.dishPosition
        dish.size = MenuPrefab.dishSize
        dish.zPosition = 5

        //To add the ingredient images and set the positions
        var i = 0
        for (key, _) in recipe.ingredientsNeeded {
            guard let ingredientCount = recipe.ingredientsNeeded[key] else {
                continue
            }
            for _ in 1...ingredientCount {
                let child = addIngredient(withType: key.type.rawValue)
                child.position = positionings[i]
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
                i += 1
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

        //Start the timer once everything has been rendered
        timer = Timer.scheduledTimer(timeInterval: StageConstants.timerInterval,
                                     target: self,
                                     selector: #selector(countdown),
                                     userInfo: nil,
                                     repeats: true)
    }

    //Adding ingredient images
    //Refactoring out this function from addRecipe to have a more modular structure
    func addIngredient(withType type: String) -> SKSpriteNode {
        //Each ingredient comes with a black circle base at the back
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
            setGreenBarSize()
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

    func setGreenBarSize() {
        self.greenBar.size =  CGSize(width: greenBar.size.width,
                                     height: StageConstants.greenBarSizeOQ.height * time / duration)
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
        self.setGreenBarSize()
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
