//
//  GameViewController.swift
//  slime
//
//  Created by Gabriel Tan on 20/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class GameViewController: ViewController<UIView> {
    private var stage: Stage!
    private var level: Level?
    private var player: Player?
    
    // multiplayer stuff
    var isMultiplayer: Bool = false
    var previousRoom: RoomModel?
    
    let newCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        collection.backgroundColor = UIColor.clear
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()

    override func configureSubviews() {
        setupScene()
    }
    
    func setLevel(level: Level) {
        self.level = level
    }
    
    func setSingleplayerUser(player: Player) {
        self.player = player
    }
    
    func setupScene() {
        guard let levelFileName = level?.fileName else {
            Logger.it.error("Level name should be set")
            fatalError()
        }
        self.context.modal.closeAllModals()
        stage = Stage()
        stage.isMultiplayer = self.isMultiplayer
        stage.setupControl()
        stage.controller = self
        let skview = SKView(frame: CGRect(x: 0.0, y: 0.0, width: ScreenSize.width, height: ScreenSize.height))
        skview.presentScene(stage)
//        skview.showsPhysics = true
//        skview.showsFPS = true
//        skview.showsNodeCount = true
        skview.isMultipleTouchEnabled = true
        view.addSubview(skview)
        
        stage.setupStage(forPlayer: player, withMultiplayerRoom: previousRoom)
        stage.generateLevel(inLevel: levelFileName)
        stage.setupPlayers()
        stage.stageDidLoad()
    }

    func setupCollection() {
        newCollection.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        newCollection.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        newCollection.heightAnchor.constraint(equalToConstant: 400).isActive = true
        newCollection.widthAnchor.constraint(equalToConstant: 225).isActive = true
    }

    func segueToMainScreen(isMultiplayer: Bool) {
        context.routeToAndPrepareFor(.StageSummary, callback: { vc in
            let summaryVC = vc as! StageSummaryController
            summaryVC.set(levelID: self.level?.id ?? "",
                          exp: self.stage.levelScore / 10,
                          score: self.stage.levelScore,
                          isMultiplayer: self.isMultiplayer)
        })
    }
    
    deinit {
        print("Game VC deinit")
    }
}
