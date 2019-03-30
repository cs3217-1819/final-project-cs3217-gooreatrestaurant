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
        self.position = CGPoint.zero
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
        ingredient.position = CGPoint(x: 0, y: -50)
        ingredient.zPosition = 5
        ingredient.size = CGSize(width: 20, height: 20)
        dish.addChild(ingredient)

        self.addChild(dish)
    }
}
