//
//  FryingEquipment.swift
//  slime
//
//  Created by Samuel Henry Kurniawan on 28/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class FryingEquipment: CookingEquipment {

    init(inPosition position: CGPoint, withSize size: CGSize = StageConstants.stationSize) {
        super.init(type: .frying,
                   inPosition: position,
                   withSize: size,
                   canProcessIngredients: [.potato])
        self.texture = kitchenwareAtlas.textureNamed("FryingPan")
        self.size = CGSize(width: 100, height: 100)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func automaticProcessing() {
        continueProcessing(withProgress: 10.0)
    }

    override func manualProcessing() {
        continueProcessing(withProgress: 10.0)
    }
}
