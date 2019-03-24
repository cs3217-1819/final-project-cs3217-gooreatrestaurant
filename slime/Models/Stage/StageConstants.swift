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
    static let maxXAxisUnits = 12000
    static let maxYAxisUnits = 10000

    static let speedMultiplier = CGFloat(1.0)
    static let jumpSpeed = 1000.0

    static let spaceshipSize = CGSize(width: 6000, height: 8000)
    static let spaceshipPosition = CGPoint(x: 6000, y: 5000)

    static let slimeSize = CGSize(width: 250, height: 300)
    static let plateSize = CGSize(width: 500, height: 100)
    static let ingredientSize = CGSize(width: 500, height: 100)
    static let cookerSize = CGSize(width: 500, height: 300)

    static let joystickSize = CGFloat(1500.0)
    static let joystickPosition = CGPoint(x: 0.1 * Double(maxXAxisUnits),
                                          y: 0.1 * Double(maxYAxisUnits))

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
