//
//  Oven.swift
//  slime
//
//  Created by Samuel Henry Kurniawan on 28/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import SpriteKit

class Oven: CookingEquipment {

    init(inPosition position: CGPoint, withSize size: CGSize = StageConstants.stationSize) {
        super.init(type: .baking,
                   inPosition: position,
                   withSize: size,
                   canProcessIngredients: [.apple, .dough])
        self.texture = SKTexture(imageNamed: "Oven")
        self.size = CGSize(width: 100, height: 100)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func automaticProcessing() {
        continueProcessing(withProgress: 100.0 / 40.0)
    }

    override func manualProcessing() {
        continueProcessing(withProgress: 0.0)
    }
}
