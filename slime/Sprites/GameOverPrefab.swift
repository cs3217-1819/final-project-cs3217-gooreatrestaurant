//
//  GameOverPrefab.swift
//  slime
//
//  Created by Developer on 6/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverPrefab: SKSpriteNode {
    var controller = GameViewController()
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        let base = SKTexture(imageNamed: "Base")
        base.filteringMode = .nearest
        let baseNode = SKSpriteNode(texture: base)
        baseNode.size = size
        baseNode.zPosition = 10

        super.init(texture: base, color: color, size: size)
        self.position = CGPoint.zero
        self.zPosition = 10

        let slime = SKSpriteNode(imageNamed: "Shocked Slime")
        slime.texture?.filteringMode = .nearest
        slime.position = CGPoint.zero
        slime.size = CGSize(width: 220, height: 220)

        let blackBG = SKSpriteNode.init(color: .black, size: CGSize(width: ScreenSize.width, height: ScreenSize.height))
        blackBG.alpha = 0.5
        blackBG.zPosition = 5

        baseNode.addChild(slime)
        baseNode.addChild(titleLabel)
        baseNode.addChild(scoreLabel)
        baseNode.addChild(replayButton)
        baseNode.addChild(exitButton)
        self.addChild(blackBG)

        self.addChild(baseNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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

    lazy var replayButton: BDButton = {
        var button = BDButton(imageNamed: "ReplayButton", buttonAction: {
            self.controller.setupScene()
        })
        button.setScale(0.35)
        button.isEnabled = true
        button.position = CGPoint(x: -80, y: -130)
        button.zPosition = StageConstants.buttonZPos
        return button
    }()

    lazy var exitButton: BDButton = {
        var button = BDButton(imageNamed: "ExitButton", buttonAction: {
            self.controller.segueToMainScreen()
        })
        button.setScale(0.35)
        button.isEnabled = true
        button.position = CGPoint(x: 80, y: -130)
        button.zPosition = StageConstants.buttonZPos
        return button
    }()

    func setScore(inScore: Int) {
        scoreLabel.text = String(inScore)
    }
}
