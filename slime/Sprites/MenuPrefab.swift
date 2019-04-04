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
    var blackBar: SKSpriteNode
    var greenBar: SKSpriteNode
    var timer: Timer =  Timer()

    var time: CGFloat = StageConstants.defaultTimeLimitOrder
    let duration: CGFloat = StageConstants.defaultTimeLimitOrder

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        let spaceshipBody = SKTexture(imageNamed: "Menu-Slimes_01")
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

    func addRecipe(inOrder: Order) {
        //Adding image of the main recipe
        let dish = SKSpriteNode(imageNamed: inOrder.recipeWanted.recipeName)
        dish.position = CGPoint(x: 0, y: 20)
        dish.zPosition = 5
        dish.size = CGSize(width: 50, height: 50)

        for (key, _) in inOrder.recipeWanted.ingredientsNeeded {
            self.addChild(addIngredient(inInt: key.type.rawValue))
        }

        //Adding the countdown bar
        blackBar.position = CGPoint(x: 35, y: -25)
        blackBar.size = CGSize(width: 45, height: 40)
        dish.addChild(blackBar)

        greenBar.anchorPoint = CGPoint(x: 0, y: 0)
        greenBar.position = CGPoint(x: -20, y: -20)
        greenBar.size = CGSize(width: 40, height: 40)
        blackBar.addChild(greenBar)

        self.addChild(dish)

        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
    }

    func addIngredient(inInt: Int) -> SKSpriteNode {
        let blackCircle = SKSpriteNode(imageNamed: "Black Base Circle")
        blackCircle.position = CGPoint(x: 0, y: -20)
        blackCircle.size = CGSize(width: 25, height: 25)

        let ingredientsAtlas = SKTextureAtlas(named: "Ingredients")
        let numImages = ingredientsAtlas.textureNames.count
        for i in 1...numImages {
            if (i == inInt) {
                //Add the ingredients
                let ingredient = SKSpriteNode(imageNamed: String(inInt))
                ingredient.size = CGSize(width: 20, height: 20)
                blackCircle.addChild(ingredient)
            }
        }

        return blackCircle
    }

    @objc func countdown() {
        if (time > 0) {
            time -= CGFloat(1.0/duration)
            self.greenBar.size =  CGSize(width: greenBar.size.width, height: self.greenBar.size.height * time / duration)
        } else {
            timer.invalidate()
        }
    }
}
