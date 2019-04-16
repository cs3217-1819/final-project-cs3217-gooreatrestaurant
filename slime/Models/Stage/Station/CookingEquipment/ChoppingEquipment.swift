//
//  ChoppingEquipment.swift
//  slime
//
//  Created by Samuel Henry Kurniawan on 29/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class ChoppingEquipment: CookingEquipment {

    init(inPosition position: CGPoint, withSize size: CGSize = StageConstants.stationSize) {
        super.init(type: .chopping,
                   inPosition: position,
                   withSize: size,
                   canProcessIngredients: [.apple, .lettuce, .carrot, .potato])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func ableToProcess(_ ingredient: Ingredient) -> Bool {
        return super.ableToProcess(ingredient) &&
               (ingredient.processed.count == 0 || ingredient.processed == [self.cookingType])
    }

    override func onProgressProcessing() {
        AudioMaster.instance.playSFX(name: "chop")
    }

    override func automaticProcessing() {
        continueProcessing(withProgress: 0.0)
    }

    override func manualProcessing() {
        continueProcessing(withProgress: 20.0)
    }
}
