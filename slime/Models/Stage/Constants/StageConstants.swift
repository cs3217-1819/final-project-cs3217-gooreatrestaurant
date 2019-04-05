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
    static let jumpSpeed = 3.5

    // node naming
    static let ingredientName = "ingredient"
    static let plateName = "plate"
    static let cookerName = "cooker"
    static let roomName = "room"
    static let slimeName = "slime"
    static let ladderName = "ladder"
    static let stationName = "station"

    // spaceship size and position
    static let spaceshipSize = CGSize(width: 400, height: 400)
    static let spaceshipPosition = CGPoint.zero

    // elements size
    static let slimeSize = CGSize(width: 25, height: 25)
    static let plateSize = CGSize(width: 30, height: 30)
    static let ingredientSize = CGSize(width: 40, height: 10)
    static let cookerSize = CGSize(width: 40, height: 30)
    static let ladderSize = CGSize(width: 50, height: 50)
    static let stationSize = CGSize(width: 40, height: 40)

    // controller size and position
    static let joystickSize = CGFloat(100)
    static let joystickPosition = CGPoint(x: ScreenSize.width * -0.5 + joystickSize / 2 + 45,
                                          y: ScreenSize.height * -0.5 + joystickSize / 2 + 45)

    static let jumpButtonPosition = CGPoint(x: ScreenSize.width * 0.5 - 90,
                                            y: ScreenSize.height * -0.5 + 45)
    static let interactButtonPosition = CGPoint(x: ScreenSize.width * 0.5 - 45,
                                            y: ScreenSize.height * -0.5 + 90)

    //timer position
    static let timerPosition = CGPoint(x: ScreenSize.width * -0.5 + 100,
                                       y: ScreenSize.height * 0.5 - 90)

    // collision bitmask
    static let wallCategoryCollision: UInt32 = 1 << 0

    // category bitmask
    static let plateCategory: UInt32 = 1 << 1
    static let ingredientCategory: UInt32 = 1 << 2
    static let tableCategory: UInt32 = 1 << 3
    static let slimeCategory: UInt32 = 1 << 4
    static let ladderCategory: UInt32 = 1 << 5
    static let stationCategory: UInt32 = 1 << 6

    // zPosition list
    static let backgroundZPos = CGFloat(-1)
    static let spaceshipZPos = CGFloat(0)
    static let ladderZPos = CGFloat(1)
    static let slimeZPos = CGFloat(5)
    static let stationZPos = CGFloat(3)
    static let joystickZPos = CGFloat(4)
    static let buttonZPos = CGFloat(4)

    // gameplay related
    static let defaultOptionalProbability = 0.5
    static let defaultTimeLimitOrder = CGFloat(10)
    static let numbersOfOrdersShown = 5
}
