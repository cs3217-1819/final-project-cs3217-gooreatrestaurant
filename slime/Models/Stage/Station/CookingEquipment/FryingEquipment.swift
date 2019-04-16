//
//  FryingEquipment.swift
//  slime
//
//  Created by Samuel Henry Kurniawan on 28/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import AVKit
import SpriteKit

class FryingEquipment: CookingEquipment {
    private var sfxPlayer: AVAudioPlayer?
    init(inPosition position: CGPoint, withSize size: CGSize = StageConstants.stationSize) {
        super.init(type: .frying,
                   inPosition: position,
                   withSize: size,
                   canProcessIngredients: [.potato])
        self.texture = kitchenwareAtlas.textureNamed("FryingPan")
        self.size = CGSize(width: 100, height: 100)

        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: self.size)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = StageConstants.stationCategory
        self.physicsBody?.contactTestBitMask = StageConstants.slimeCategory
        self.physicsBody?.collisionBitMask = StageConstants.wallCategoryCollision
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func onStartProcessing() {
        sfxPlayer = AudioMaster.instance.playSeparateSFX(name: "frying")
    }
    
    override func onEndProcessing() {
        if let player = sfxPlayer {
            sfxPlayer?.stop()
            sfxPlayer = nil
            AudioMaster.instance.playSFX(name: "oven-ding")
        }
    }

    override func denyProcessing(ofItem item: Item?) -> Bool {
        guard let ingredient = item as? Ingredient else {
            return false
        }

        if ingredient.type == .potato && !ingredient.processed.contains(.chopping) {
            return true
        }
        return false
    }

    // 20 per seconds
    override func automaticProcessing() {
        continueProcessing(withProgress: 100.0 / 80.0)
    }

    override func manualProcessing() {
        continueProcessing(withProgress: 0)
    }
}
