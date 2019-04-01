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

    var time: CGFloat = 10
    var timer: Timer =  Timer()
    var progressIncrement:Float = 0

    let duration:Float = 10.0

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        self.blackBar = SKSpriteNode(imageNamed: "Black bar")
        self.greenBar = SKSpriteNode(imageNamed: "Green bar")

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
        blackBar.position = CGPoint(x: 35, y: -25)
        blackBar.size = CGSize(width: 45, height: 40)
        dish.addChild(blackBar)

        greenBar.anchorPoint = CGPoint(x: 0, y: 0)
        greenBar.position = CGPoint(x: -20, y: -20)
        greenBar.size = CGSize(width: 40, height: 40)
        blackBar.addChild(greenBar)

        self.addChild(dish)

        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(temp), userInfo: nil, repeats: true)
    }

    @objc func temp() {
        if (time > 0) {
            print("A")
//            var value = lerp(min: 0, max: 1, value: self.greenBar.size.height * time)
//            print(value)
            var temp = CGFloat(TimeInterval(time))
            temp = CGFloat(1.0/duration)
            time -= temp
            print(time)
            print(time/10.0)
            self.greenBar.size =  CGSize(width: greenBar.size.width, height: self.greenBar.size.height * time/10.0)
        } else {
            timer.invalidate()
        }
    }

    func lerp(min: CGFloat, max: CGFloat, value: CGFloat) -> CGFloat {
        return min + (value * (max - min))
    }
}
