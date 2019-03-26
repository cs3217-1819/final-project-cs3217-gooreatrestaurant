//
//  GameViewController.swift
//  slime
//
//  Created by Gabriel Tan on 20/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
   override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // for user testing
        // TO DO: remove this
        let stage = Stage()
        let skview = SKView(frame: view.safeAreaLayoutGuide.layoutFrame)
        skview.frame = CGRect(x: 0.0, y: 0.0, width: ScreenSize.width, height: ScreenSize.height)
        let scene = GameScene(size: CGSize(width: ScreenSize.width, height: ScreenSize.height))
        scene.scaleMode = .aspectFill
        // skview.presentScene(scene)
        skview.presentScene(stage)
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        view.addSubview(skview)
        stage.spaceship.addSlime(inPosition: CGPoint(x: 0, y: -50))
        stage.spaceship.addRoom(inPosition: CGPoint.zero, withSize: CGSize(width: 100, height: 100))
        stage.spaceship.addWalls(inLevel: "Level 1")
        stage.spaceship.addWalls(inLevel: "Level1UnaccessibleArea")
        stage.spaceship.addLadder(inPosition: CGPoint(x: -100, y: -21))
        stage.spaceship.addLadder(inPosition: CGPoint(x: -100, y: -50))
    
        stage.spaceship.addLadder(inPosition: CGPoint(x: -60, y: -135))
        stage.spaceship.addLadder(inPosition: CGPoint(x: -60, y: -90))
        stage.spaceship.addLadder(inPosition: CGPoint(x: -60, y: -45))
        stage.spaceship.addLadder(inPosition: CGPoint(x: -60, y: 0))
        stage.spaceship.addLadder(inPosition: CGPoint(x: -60, y: 45))

        stage.spaceship.addLadder(inPosition: CGPoint(x: 90, y: -25))
        stage.spaceship.addLadder(inPosition: CGPoint(x: 90, y: 20))
        stage.spaceship.addLadder(inPosition: CGPoint(x: 90, y: 65))
//        stage.spaceship.addIngredients(type: .potato, inPosition: pos4)
//        stage.spaceship.addCooker(type: .frying, inPosition: pos5)
    }

    lazy var skView: SKView = {
        let view = SKView()
        //        view.translatesAutoresizingMaskIntoConstraints = false
        view.isMultipleTouchEnabled = true
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
