//
//  StageConstants.swift
//  GooreatRestaurant
//
//  Created by Samuel Henry Kurniawan on 14/3/19.
//  Copyright © 2019 CS3217. All rights reserved.
//

import UIKit

class StageConstants {

    static let maxPlayer = 4
    static let maxXAxisUnits = ScreenSize.width
    static let maxYAxisUnits = ScreenSize.height

    static let speedMultiplier = CGFloat(1.0)
    static let jumpSpeed = 1000.0

    static let spaceshipSize = CGSize(width: 400, height: 400)
    static let spaceshipPosition = CGPoint.zero

    static let slimeSize = CGSize(width: 300, height: 300)
    static let plateSize = CGSize(width: 500, height: 100)
    static let ingredientSize = CGSize(width: 500, height: 100)
    static let cookerSize = CGSize(width: 500, height: 300)

    static let joystickSize = CGFloat(100)
    static let joystickPosition = CGPoint(x: ScreenSize.width * -0.5 + joystickSize / 2 + 45,
                                          y: ScreenSize.height * -0.5 + joystickSize / 2 + 45)

    static let jumpButtonPosition = CGPoint(x: 0.9 * Double(maxXAxisUnits),
                                            y: 0.1 * Double(maxYAxisUnits))

    static let wallCategoryCollision: UInt32 = 1 << 0

    enum IngredientType {
        case potato
        case junk
    }

    enum FoodType {
        case fries
        case junk
    }

    enum CookingType {
        case frying
    }

    static let wayToCook: [IngredientType: CookingType] = [.potato: .frying]
    static let recipes: [Food] = []
}
