//
//  GameViewController.swift
//  slime
//
//  Created by Gabriel Tan on 20/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! IngredientsCell
//        cell.backgroundColor  = .white
//        cell.layer.cornerRadius = 5
//        cell.layer.shadowOpacity = 3
        cell.imageView.image = UIImage(named: "Menu-Slimes_01")
        return cell
    }

    let newCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: CGRect(x: 0, y: 0, width: 500, height: 500), collectionViewLayout: layout)
//        layout.scrollDirection = .horizontal
        collection.backgroundColor = UIColor.clear
//        collection.translatesAutoresizingMaskIntoConstraints = false
//        collection.isScrollEnabled = true
        return collection
    }()

   override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // for user testing
        // TO DO: remove this
        let stage = Stage()
        let skview = SKView(frame: view.safeAreaLayoutGuide.layoutFrame)
        skview.frame = CGRect(x: 0.0, y: 0.0, width: ScreenSize.width, height: ScreenSize.height)
        skview.presentScene(stage)
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        view.addSubview(skview)

        stage.generateLevel(inLevel: "Level1")

        newCollection.delegate = self
        newCollection.dataSource = self
        newCollection.register(IngredientsCell.self, forCellWithReuseIdentifier: "MyCell")
        view.addSubview(newCollection)
        setupCollection()
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

    func setupCollection(){
        newCollection.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        newCollection.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        newCollection.heightAnchor.constraint(equalToConstant: 200  ).isActive = true
        newCollection.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
