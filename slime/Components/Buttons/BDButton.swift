//
//  BDButton.swift
//  slime
//
//  Created by Developer on 20/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import SpriteKit

class BDButton: SKNode {
    var button: SKSpriteNode
    var isEnabled = false
    private var mask: SKSpriteNode
    private var cropNode: SKCropNode
    private var action:() -> Void

    init(inTexture: SKTexture, buttonAction: @escaping () -> Void) {
        button = SKSpriteNode(texture: inTexture)

        mask = SKSpriteNode(color: SKColor.black, size: button.size)
        mask.alpha = 0

        cropNode = SKCropNode()
        cropNode.maskNode = button
        cropNode.zPosition = 3
        cropNode.addChild(mask)

        action = {
            AudioMaster.instance.playSFX(name: "selection")
            buttonAction()
        }

        super.init()

        isUserInteractionEnabled = true

        setupNodes()
        addNodes()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupNodes() {
        button.zPosition = 0
    }

    func addNodes() {
        addChild(button)
        addChild(cropNode)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isEnabled {
            mask.alpha = 0.5
            //run(SKAction.scale(by: 1.05, duration: 0.05))
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isEnabled {
            for touch in touches {
                let location: CGPoint = touch.location(in: self)
                if button.contains(location) {
                    mask.alpha = 0.5
                } else {
                    mask.alpha = 0
                }
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isEnabled {
            for touch in touches {
                let location: CGPoint = touch.location(in: self)
                if button.contains(location) {
                    disable()
                    action()
                    run(SKAction.sequence([SKAction.wait(forDuration: 0.2), SKAction.run {
                        self.enable()
                        }]))
                }
            }
        }
    }

    func disable() {
        isEnabled = false
        mask.alpha = 0
        button.alpha = 0.5
    }

    func enable() {
        isEnabled = true
        mask.alpha = 0
        button.alpha = 1
    }
}
