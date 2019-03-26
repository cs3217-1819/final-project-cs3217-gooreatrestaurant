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

<<<<<<< HEAD
        stage.spaceship.addSlime(inPosition: CGPoint.zero)
=======
        //temporarily, just for testing
        // TO DO: remove this
//        let pos1 = CGPoint(x: -1000, y: 0)
//        let pos4 = CGPoint(x: -500, y: -950)
//        let pos5 = CGPoint(x: -1400, y: -950)
//        let pos6 = CGPoint(x: 1500, y: -950)
//        let pos2 = CGPoint(x: 0, y: -500)
//        let pos3 = CGPoint(x: 1000, y: 0)
//        let size1 = CGSize(width: 1000, height: 2000)
//        let size2 = CGSize(width: 1000, height: 1000)
//
//        let path1 = [CGPoint(x: -1500, y: -1000),
//                     CGPoint(x: 1500, y: -1000),
//                     CGPoint(x: 1500, y: 1000),
//                     CGPoint(x: 500, y: 1000),
//                     CGPoint(x: 500, y: 0),
//                     CGPoint(x: -500, y: 0),
//                     CGPoint(x: -500, y: 1000),
//                     CGPoint(x: -1500, y: 1000)]
//
//        // stage?.spaceship.addWalls(path1)
//        stage.spaceship.addRoom(inPosition: pos1, withSize: size1)
//        stage.spaceship.addRoom(inPosition: pos2, withSize: size2)
//        stage.spaceship.addRoom(inPosition: pos3, withSize: size1)
//        stage.spaceship.addWalls(withPoints: path1)
        stage.spaceship.addSlime(inPosition: CGPoint(x: 0, y: -50))
>>>>>>> master
        stage.spaceship.addRoom(inPosition: CGPoint.zero, withSize: CGSize(width: 100, height: 100))
        stage.spaceship.addWalls(inLevel: "Level 1")
        stage.spaceship.addWalls(inLevel: "Level1UnaccessibleArea")
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
