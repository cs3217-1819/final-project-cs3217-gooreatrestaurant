//
//  MenuPrefab.swift
//  slime
//
//  Created by Developer on 30/3/19.
//  Copyright © 2019 nus.cs3217.a0143378y. All rights reserved.
//

import Foundation
import SpriteKit

class MenuPrefab : SKSpriteNode, UICollectionViewDelegate {
    var blackBar: SKSpriteNode
    var greenBar: SKSpriteNode
    var timer: Timer =  Timer()

    var time: CGFloat = 10.0
    let duration: CGFloat = 10.0

//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 2
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath as IndexPath)
//        myCell.backgroundColor = UIColor.blue
//        return myCell
//    }
//
//    func temp() -> UICollectionView {
//        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
//        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
//        layout.itemSize = CGSize(width: 60, height: 60)
//
//        let myCollectionView:UICollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 30, height: 30), collectionViewLayout: layout)
////        myCollectionView.dataSource = self
//        myCollectionView.delegate = self
//        myCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "MyCell")
//        myCollectionView.backgroundColor = UIColor.clear
//        return myCollectionView
//    }

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

        self.addChild(addIngredient(inString: "Apple"))

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

    func addIngredient(inString: String) -> SKSpriteNode {
        let blackCircle = SKSpriteNode(imageNamed: "Black Base Circle")
        blackCircle.position = CGPoint(x: 0, y: -20)
        blackCircle.size = CGSize(width: 25, height: 25)

        //Add the ingredients
        let ingredient = SKSpriteNode(imageNamed: inString)
        ingredient.size = CGSize(width: 15, height: 15)
        blackCircle.addChild(ingredient)

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
