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
    static let jumpSpeed = 10.0

    static let spaceshipSize = CGSize(width: 400, height: 400)
    static let spaceshipPosition = CGPoint.zero

    static let slimeSize = CGSize(width: 30, height: 30)
    static let plateSize = CGSize(width: 40, height: 40)
    static let ingredientSize = CGSize(width: 40, height: 20)
    static let cookerSize = CGSize(width: 40, height: 30)

    static let joystickSize = CGFloat(100)
    static let joystickPosition = CGPoint(x: ScreenSize.width * -0.5 + joystickSize / 2 + 45,
                                          y: ScreenSize.height * -0.5 + joystickSize / 2 + 45)

    static let jumpButtonPosition = CGPoint(x: ScreenSize.width * 0.5 - 45,
                                            y: ScreenSize.height * -0.5 + 45)

    // collision bitmask
    static let wallCategoryCollision: UInt32 = 1 << 0

    // category bitmask
    static let cookerCategory: UInt32 = 1 << 0
    static let plateCategory: UInt32 = 1 << 1
    static let ingredientCategory: UInt32 = 1 << 2
    static let tableCategory: UInt32 = 1 << 3
    static let slimeCategory: UInt32 = 1 << 4
    static let ladderCategory: UInt32 = 1 << 5

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
