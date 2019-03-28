//
//  Oven.swift
//  slime
//
//  Created by Samuel Henry Kurniawan on 28/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class Oven: CookingEquipment {

    init(inPosition position: CGPoint, withSize size: CGSize = StageConstants.stationSize) {
        super.init(type: .baking,
                   inPosition: position,
                   withSize: size,
                   canProcessIngredients: [.potato])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
