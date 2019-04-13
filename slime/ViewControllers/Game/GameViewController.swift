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
    
    var db: GameDatabase = GameDB()
    
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
        let stage = Stage()
        stage.isMultiplayer = self.isMultiplayer
        stage.setupControl()
        stage.controller = self
        let skview = SKView(frame: CGRect(x: 0.0, y: 0.0, width: ScreenSize.width, height: ScreenSize.height))
        skview.presentScene(stage)
        skview.showsPhysics = true
        skview.showsFPS = true
        skview.showsNodeCount = true
        skview.isMultipleTouchEnabled = true
        view.addSubview(skview)

        // TODO: multiplayer stuff, add all the players to stage, then the setupPlayers() will map the slime to player
        if isMultiplayer { if let room = self.previousRoom { stage.setupMultiplayer(forRoom: room) }}
        if !isMultiplayer { stage.setupSinglePlayer() }

        stage.generateLevel(inLevel: "Level1")

        //        newCollection.delegate = self
        //        newCollection.dataSource = self
        //        newCollection.register(IngredientsCell.self, forCellWithReuseIdentifier: "MyCell")
        //        view.addSubview(newCollection)
        //        setupCollection()

        stage.setupPlayers()
    }

    func setupCollection() {
        newCollection.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        newCollection.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        newCollection.heightAnchor.constraint(equalToConstant: 400).isActive = true
        newCollection.widthAnchor.constraint(equalToConstant: 225).isActive = true
    }

    func segueToMainScreen() {
        let control: StageSummaryController = context.routeToAndPrepareForFade(.StageSummary)
        control.set(exp: 80, score: 300, isMultiplayer: false)
    }
    deinit {
        print("Game VC deinit")
    }
}

//class CollectionDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        // need to change this somehow since now there is minimum and maximum
//        return StageConstants.minNumbersOfOrdersShown
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! IngredientsCell
//        cell.imageView.image = UIImage(named: "Menu-Slimes_01")
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 100, height: 100)
//    }
//
////    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
////        return UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
////    }
//}
