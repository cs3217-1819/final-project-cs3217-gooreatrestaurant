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
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        print("Appeared")
//
//        // for user testing
//        // TO DO: remove this
//        let game = Game()
//        game.addStage(withName: "test")
//        _ = game.playStage(withName: "test")
//        let stage = game.stagePlaying
//        let skview = SKView(frame: view.safeAreaLayoutGuide.layoutFrame)
//        let scene = GameScene(size: CGSize(width: ScreenSize.width, height: ScreenSize.height))
//        scene.scaleMode = .aspectFill
//        skview.presentScene(scene)
//        //skview.presentScene(stage)
//        view.addSubview(skview)
//
//        //temporarily, just for testing
//        // TO DO: remove this
//        let pos1 = CGPoint(x: -2000, y: 0)
//        let pos4 = CGPoint(x: -1000, y: -1850)
//        let pos5 = CGPoint(x: -2800, y: -1850)
//        let pos6 = CGPoint(x: 3000, y: -1850)
//        let pos2 = CGPoint(x: 0, y: -1000)
//        let pos3 = CGPoint(x: 2000, y: 0)
//        let size1 = CGSize(width: 2000, height: 4000)
//        let size2 = CGSize(width: 2000, height: 2000)
//
//        let path1 = CGMutablePath()
//        path1.move(to: CGPoint(x: -3000, y: -2000))
//        path1.addLine(to: CGPoint(x: 3000, y: -2000))
//        path1.addLine(to: CGPoint(x: 3000, y: 2000))
//        path1.addLine(to: CGPoint(x: 1000, y: 2000))
//        path1.addLine(to: CGPoint(x: 1000, y: 0))
//        path1.addLine(to: CGPoint(x: -1000, y: 0))
//        path1.addLine(to: CGPoint(x: -1000, y: 2000))
//        path1.addLine(to: CGPoint(x: -3000, y: 2000))
//        path1.addLine(to: CGPoint(x: -3000, y: -2000))
//
//        // stage?.spaceship.addWalls(path1)
//        stage?.spaceship.addRoom(inPosition: pos1, withSize: size1)
//        stage?.spaceship.addRoom(inPosition: pos2, withSize: size2)
//        stage?.spaceship.addRoom(inPosition: pos3, withSize: size1)
//        stage?.spaceship.addSlime(inPosition: pos4)
//        stage?.spaceship.addIngredients(type: .potato, inPosition: pos4)
//        stage?.spaceship.addCooker(type: .frying, inPosition: pos5)
//
//        stage?.spaceship.slimes[0].jump()
//        stage?.spaceship.slimes[0].interact()
//        stage?.spaceship.slimes[0].moveLeft()
//    }

    lazy var skView: SKView = {
        let view = SKView()
        //        view.translatesAutoresizingMaskIntoConstraints = false
        view.isMultipleTouchEnabled = true
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    fileprivate func setupViews() {
        view.addSubview(skView)
        skView.frame = CGRect(x: 0.0, y: 0.0, width: ScreenSize.width, height: ScreenSize.height)
        let scene = GameScene(size: CGSize(width: ScreenSize.width, height: ScreenSize.height))
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsPhysics = true
    }
}
