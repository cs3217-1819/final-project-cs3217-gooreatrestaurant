//
//  MenuPrefab.swift
//  slime
//
//  Created by Developer on 30/3/19.
//  Copyright © 2019 nus.cs3217.a0143378y. All rights reserved.
//

import Foundation
import SpriteKit

class MenuPrefab : SKSpriteNode {
    var recipe: Recipe?

    var blackBar: SKSpriteNode
    var greenBar: SKSpriteNode
    var timer: Timer =  Timer()

    var time: CGFloat = StageConstants.defaultTimeLimitOrder
    let duration: CGFloat = StageConstants.defaultTimeLimitOrder

    let positionings = [CGPoint(x: -10, y: -15),
                        CGPoint(x: 10, y: -15)]

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        let randNum = Int.random(in: 1...4)
        let spaceshipBody = SKTexture(imageNamed: "Menu-Slimes_" + String(randNum))
        spaceshipBody.filteringMode = .nearest

        self.blackBar = SKSpriteNode(imageNamed: "Black bar")
        self.greenBar = SKSpriteNode(imageNamed: "Green bar")

        super.init(texture: spaceshipBody, color: color, size: size)
        self.position = CGPoint(x: ScreenSize.width * 0.5 - 60,
                                y: ScreenSize.height * 0.5 - 60)
        self.zPosition = 5
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addRecipe(_ recipe: Recipe, inPosition: CGPoint) {
        self.position = inPosition
        self.recipe = recipe
        //Adding image of the main recipe
        let dish = SKSpriteNode(imageNamed: recipe.recipeName)
        dish.position = CGPoint(x: 0, y: 20)
        dish.zPosition = 5
        dish.size = CGSize(width: 45, height: 45)

        var i = 0
        for (key, _) in recipe.ingredientsNeeded {
            let child = addIngredient(withType: key.type.rawValue)
            child.position = positionings[i]
            i += 1
            self.addChild(child)
        }

        //Adding the countdown bar
        blackBar.position = CGPoint(x: 25, y: -25)
        blackBar.size = CGSize(width: 35, height: 30)
        dish.addChild(blackBar)

        greenBar.anchorPoint = CGPoint(x: 0, y: 0)
        greenBar.position = CGPoint(x: -15, y: -15)
        greenBar.size = CGSize(width: 30, height: 30)
        blackBar.addChild(greenBar)

        self.addChild(dish)

        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
    }

    func addIngredient(withType type: String) -> SKSpriteNode {
        let blackCircle = SKSpriteNode(imageNamed: "Black Base Circle")
        blackCircle.position = CGPoint(x: 0, y: -20)
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
            time -= CGFloat(1.0/duration)
            self.greenBar.size =  CGSize(width: greenBar.size.width, height: self.greenBar.size.height * time / duration)
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
}
