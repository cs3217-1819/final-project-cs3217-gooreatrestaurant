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

class GameViewController: UIViewController {
    
    var db: GameDatabase = GameDB()
    
    var isMultiplayer: Bool = false
    var multiplayerGameId: String?
    var previousRoom: RoomModel?
    var players: [RoomPlayerModel]?
    var currentMap: String?
    
    let newCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        collection.backgroundColor = UIColor.clear
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()

   override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let stage = Stage()
        let skview = SKView(frame: view.safeAreaLayoutGuide.layoutFrame)
        skview.frame = CGRect(x: 0.0, y: 0.0, width: ScreenSize.width, height: ScreenSize.height)
        skview.presentScene(stage)
        skview.showsPhysics = true
        skview.showsFPS = true
        skview.showsNodeCount = true
        skview.isMultipleTouchEnabled = true
        view.addSubview(skview)

        stage.generateLevel(inLevel: "Level1")

        let bgm = AudioController()
        bgm.playMusic("GameSong", true)
        //        newCollection.delegate = self
        //        newCollection.dataSource = self
        //        newCollection.register(IngredientsCell.self, forCellWithReuseIdentifier: "MyCell")
        //        view.addSubview(newCollection)
        //        setupCollection()
        
        // TODO: multiplayer stuff, add all the players to stage, then the setupPlayers() will map the slime to player
        if isMultiplayer {
            joinGame()
        } else {
            guard let onlyUser = GameAuth.currentUser else {
                return
            }
            // Level 1 here only placeholder TO DO
            let onlyPlayer = Player(name: onlyUser.uid, level: 1)
            stage.addPlayer(onlyPlayer)
        }
        stage.setupPlayers()
    }
    
    private func joinGame() {
        guard let id = self.multiplayerGameId else {
            return
        }
        
        self.db.joinGame(forGameId: id, {
            self.setupMultiplayer()
        }) { (err) in
            print(err)
        }
    }
    
    private func isUserHost() -> Bool {
        guard let user = GameAuth.currentUser else {
            return false
        }
        
        for player in self.players ?? [] {
            if player.uid != user.uid { continue }
            return player.isHost
        }
        
        return false
    }
    
    private func setupMultiplayer() {
        guard let room = previousRoom else {
            return
        }
        
        db.observeGameState(forRoom: room, onPlayerUpdate: { (player) in
            // this occurs when a player's
            // state in the database changes
            print(player.positionX)
            print(player.positionY)
            print(player.uid)
            // it handles all of the players individually
        }, onStationUpdate: {
            // not yet implemented
            // this updates whenever one station
            // experiences a change
        }, onGameEnd: {
            print("Game has ended")
        }, onOrderChange: { (orders) in
            // the function here occurs everytime the
            // order in the db changes
            for order in orders {
                print(order.name)
            }
        }, onScoreChange: { (score) in
            // self-explanatory
            print(score)
        }, onAllPlayersReady: {
            // only for host, start game
            guard let room = self.previousRoom else { return }
            
            self.db.startGame(forRoom: room, {
            }, { (err) in
                print(err)
            })
        }) { (err) in
            print(err)
        }
    }

    func setupCollection() {
        newCollection.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        newCollection.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        newCollection.heightAnchor.constraint(equalToConstant: 400).isActive = true
        newCollection.widthAnchor.constraint(equalToConstant: 225).isActive = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension GameViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // need to change this somehow since now there is minimum and maximum
        return StageConstants.minNumbersOfOrdersShown
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! IngredientsCell
        cell.imageView.image = UIImage(named: "Menu-Slimes_01")
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
//    }
}
