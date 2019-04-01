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
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        self.position = CGPoint(x: ScreenSize.width * 0.5 - 60,
                                y: ScreenSize.height * 0.5 - 60)
        self.zPosition = 5
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addRecipe(inString: String) {
        //Adding image of the main recipe
        let dish = SKSpriteNode(imageNamed: inString)
        dish.position = CGPoint(x: 0, y: 20)
        dish.zPosition = 5
        dish.size = CGSize(width: 50, height: 50)

        //Add the ingredients
        let ingredient = SKSpriteNode(imageNamed: "Apple")
        ingredient.position = CGPoint(x: 0, y: -40)
        ingredient.size = CGSize(width: 20, height: 20)
        dish.addChild(ingredient)

        //Adding the countdown bar
        let blackBar = SKSpriteNode(imageNamed: "Black bar")
        blackBar.position = CGPoint(x: 35, y: -25)
        blackBar.size = CGSize(width: 45, height: 40)
        dish.addChild(blackBar)

        let greenBar = SKSpriteNode(imageNamed: "Green bar")
        greenBar.anchorPoint = CGPoint(x: 0, y: 0)
        greenBar.position = CGPoint(x: -20, y: -20)
        greenBar.size = CGSize(width: 40, height: 40)
        blackBar.addChild(greenBar)

        self.addChild(dish)

        countdown(inBar: greenBar)
    }

    func countdown(inBar: SKSpriteNode) {

        var height = inBar.size.height
//        for i in 1...10 {
//            print(i)
//            height = height * CGFloat(i)
//            inBar.size = CGSize(width: inBar.size.width, height: height)
//        }
         inBar.size = CGSize(width: inBar.size.width, height: height * 0.2)
    }
}
