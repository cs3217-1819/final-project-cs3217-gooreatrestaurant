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
        stage.spaceship.addRoom()
        stage.spaceship.addWalls(inLevel: "Level 1")
        stage.spaceship.addWalls(inLevel: "Level1UnaccessibleArea")
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
