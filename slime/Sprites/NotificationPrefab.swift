//
//  NotificationPrefab.swift
//  slime
//
//  Created by Johandy Tantra on 14/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import SpriteKit

class NotificationPrefab: SKSpriteNode {
    var isMultiplayer: Bool = false
    var descriptionLabel: SKLabelNode?
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        let base = SKTexture(imageNamed: "button-red")
        base.filteringMode = .nearest

        super.init(texture: base, color: color, size: size)
        self.position = StageConstants.notificationPosition
        self.zPosition = 10
        self.alpha = 0.0
        
        let label = SKLabelNode(fontNamed: "SquidgySlimes")
        self.descriptionLabel = label
        label.fontSize = CGFloat(17)
        label.zPosition = 10
        label.alpha = 1.0
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.text = ""
        label.fontColor = UIColor(red: 60, green: 60, blue: 60)
        label.position = CGPoint(x: 0.0, y: 0.0)
        
        self.addChild(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(withDescription description: String, ofType type: NotificationTypes) {
        self.descriptionLabel?.text = description
        
        var texture: SKTexture?
        
        switch type {
        case .warning:
            print("hello")
            texture = SKTexture(imageNamed: "button-red")
            self.descriptionLabel?.fontColor = UIColor(red: 255, green: 255, blue: 255)
        case .info:
            texture = SKTexture(imageNamed: "button-blue")
            self.descriptionLabel?.fontColor = UIColor(red: 0, green: 0, blue: 0)
        }
        
        guard let skTexture = texture else { return }
        let changeTexture = SKAction.setTexture(skTexture)
        
        let fadeOutFirstAction = SKAction.fadeAlpha(to: 0.0, duration: 0.0)
        let fadeInAction = SKAction.fadeAlpha(to: 1.0, duration: 0.3)
        let waitAction = SKAction.wait(forDuration: 1.5)
        let fadeOutAction = SKAction.fadeAlpha(to: 0.0, duration: 0.3)
        
        let sequence = SKAction.sequence([changeTexture, fadeOutFirstAction, fadeInAction, waitAction, fadeOutAction])
        
        self.run(sequence)
    }
    
    enum NotificationTypes: String {
        case warning = "warning"
        case info = "info"
    }
}
