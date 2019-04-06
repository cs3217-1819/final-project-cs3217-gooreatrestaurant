//
//  GameOverPrefab.swift
//  slime
//
//  Created by Developer on 6/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverPrefab : SKSpriteNode {
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        let base = SKTexture(imageNamed: "Border")
        base.filteringMode = .nearest

        super.init(texture: base, color: color, size: size)
        self.position = CGPoint.zero
        self.zPosition = 10

        self.addChild(titleLabel)
        self.addChild(replayButton)
        self.addChild(exitButton)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var titleLabel: SKLabelNode =  {
        var label = SKLabelNode(fontNamed: "SquidgySlimes")
        label.fontSize = CGFloat(30)
        label.zPosition = 10
        label.color = .red
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .top
        label.text = "GAME OVER"
        label.position = CGPoint.zero
        return label
    }()

    lazy var scoreLabel: SKLabelNode =  {
        var label = SKLabelNode(fontNamed: "SquidgySlimes")
        label.fontSize = CGFloat(60)
        label.zPosition = 10
        label.color = .red
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.text = ""
        label.position = CGPoint.zero
        return label
    }()

    lazy var replayButton: BDButton = {
        var button = BDButton(imageNamed: "ReplayButton", buttonAction: {
            print("REPLAY GAME")
        })
        button.setScale(0.1)
        button.isEnabled = true
        button.position = CGPoint(x: -50, y: -100)
        button.zPosition = StageConstants.buttonZPos
        return button
    }()

    lazy var exitButton: BDButton = {
        var button = BDButton(imageNamed: "ExitButton", buttonAction: {
            print("EXIT GAME")
        })
        button.setScale(0.1)
        button.isEnabled = true
        button.position = CGPoint(x: 50, y: -100)
        button.zPosition = StageConstants.buttonZPos
        return button
    }()

    func setScore(inScore: Int) {
        scoreLabel.text = String(inScore)
    }
}
