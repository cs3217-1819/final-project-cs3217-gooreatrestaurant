//
//  GameOverPrefab.swift
//  slime
//
//  Created by Developer on 6/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import Foundation
import SpriteKit

/*
 Game Over Prefab is for generating the end game scene at the end
 This consists of:
 - Base background
 - Shocked Slime (just for graphics purposes)
 - Replay button
 - Back to main menu button
 The game Over Prefab will be different in the single player and the multiplayer scene
 */
class GameOverPrefab: SKSpriteNode {
    var controller = GameViewController(with: UIView())
    var isMultiplayer: Bool = false
    var baseNode: SKSpriteNode?
    let UIAtlas = SKTextureAtlas(named: "UI")
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        //Background
        let base = SKTexture(imageNamed: "Base")
        base.filteringMode = .nearest
        let baseNode = SKSpriteNode(texture: base)
        self.baseNode = baseNode
        baseNode.size = size
        baseNode.zPosition = StageConstants.endgameBasenodeZPos

        super.init(texture: base, color: color, size: size)
        self.position = CGPoint.zero
        self.zPosition = StageConstants.endgameZPos

        //Shocked Slime
        let slime = SKSpriteNode(texture: UIAtlas.textureNamed("ShockedSlime"))
        slime.texture?.filteringMode = .nearest
        slime.position = CGPoint.zero
        slime.size = CGSize(width: 220, height: 220)

        //black background for blocking the rest of scene and buttons
        let blackBG = SKSpriteNode.init(color: .black, size: CGSize(width: ScreenSize.width, height: ScreenSize.height))
        blackBG.alpha = 0.5
        blackBG.zPosition = StageConstants.blackBGOpeningZPos
        baseNode.addChild(slime)
        self.addChild(blackBG)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initializeButtons() {
        //Adding the buttons separately
        guard let baseNode = self.baseNode else { return }
        baseNode.addChild(titleLabel)
        baseNode.addChild(scoreLabel)
        if let replay = replayButton { baseNode.addChild(replay) }
        baseNode.addChild(exitButton)
        self.addChild(baseNode)
    }
    
    func setToMultiplayer() {
        self.isMultiplayer = true
    }

    //Initializing the graphics that is needed for the prefab
    lazy var titleLabel: SKLabelNode = {
        var label = SKLabelNode(fontNamed: "SquidgySlimes")
        label.fontSize = CGFloat(60)
        label.zPosition = 10
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .top
        label.text = "GAME OVER"
        label.fontColor = UIColor(red: 53, green: 53, blue: 53)
        label.position = CGPoint(x: 0, y: 120)
        return label
    }()

    lazy var scoreLabel: SKLabelNode = {
        var label = SKLabelNode(fontNamed: "SquidgySlimes")
        label.fontSize = CGFloat(50)
        label.zPosition = 10
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.text = ""
        label.position = CGPoint(x: 0, y: -85)
        return label
    }()

    lazy var replayButton: BDButton? = {
        if isMultiplayer { return nil }
        let texture = UIAtlas.textureNamed("TryAgainButton")
        var button = BDButton(inTexture: texture, buttonAction: {
            self.controller.setupScene()
        })
        button.setScale(0.35)
        button.isEnabled = true
        button.position = CGPoint(x: -80, y: -130)
        button.zPosition = StageConstants.buttonZPos
        return button
    }()

    lazy var exitButton: BDButton = {
        let texture = UIAtlas.textureNamed("ReturnToMMButton")
        var button = BDButton(inTexture: texture, buttonAction: {
            self.controller.segueToMainScreen(isMultiplayer: self.isMultiplayer)
        })
        button.setScale(0.35)
        button.isEnabled = true
        button.position = CGPoint(x: (isMultiplayer ? 0 : 80), y: -130)
        button.zPosition = StageConstants.buttonZPos
        return button
    }()

    func setScore(inScore: Int) {
        scoreLabel.text = String(inScore)
    }
}
