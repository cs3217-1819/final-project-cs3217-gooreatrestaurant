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
    var notificationType: NotificationTypes = .info
    var descriptionLabel: SKLabelNode?
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        let base = SKTexture(imageNamed: "button-red")
        base.filteringMode = .nearest
        let baseNode = SKSpriteNode(texture: base)
        baseNode.size = size
        baseNode.zPosition = 10
        
        super.init(texture: base, color: color, size: size)
        self.position = StageConstants.notificationPosition
        self.zPosition = 10
        self.alpha = 0.0
        
        let label = SKLabelNode(fontNamed: "SquidgySlimes")
        self.descriptionLabel = label
        label.fontSize = CGFloat(100)
        label.zPosition = 10
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .top
        label.text = "i am grootAAAAAAAAAAAAAAAAAKNWNVOIWNKACNOIEMCSNCSAOSCINE"
        label.fontColor = UIColor(red: 60, green: 60, blue: 60)
        label.position = CGPoint(x: 0.0, y: 100)
        
        baseNode.addChild(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setNotificationDescription(_ string: String) {
        self.descriptionLabel?.text = string
    }
    
    func setNotificationType(_ type: NotificationTypes) {
        self.notificationType = type
        let base = SKTexture(imageNamed: "button-red")
        self.texture = base
    }
    
    func show() {
        let fadeInAction = SKAction.fadeAlpha(to: 1.0, duration: 0.3)
        let waitAction = SKAction.wait(forDuration: 1.5)
        let fadeOutAction = SKAction.fadeAlpha(to: 0.0, duration: 0.3)
        
        let sequence = SKAction.sequence([fadeInAction, waitAction, fadeOutAction])
        
        self.run(sequence)
    }
    
    func destroy() {
        self.removeAllActions()
        let fadeOutAction = SKAction.fadeAlpha(to: 0.0, duration: 0.1)
        
        self.run(fadeOutAction)
    }
    
    enum NotificationTypes {
        case warning
        case info
    }
}
