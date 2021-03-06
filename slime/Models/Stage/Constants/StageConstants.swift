//
//  StageConstants.swift
//  GooreatRestaurant
//
//  Created by Samuel Henry Kurniawan on 14/3/19.
//  Copyright © 2019 CS3217. All rights reserved.
//

import UIKit

class StageConstants {
    // should put the stage time in the plist
    static let stageTime = 200
    static let multiplayerStageTime = 250
    
    static let maxPlayer = 4
    static let maxXAxisUnits = ScreenSize.width
    static let maxYAxisUnits = ScreenSize.height

    static let speedMultiplier: CGFloat = 6.0
    static let jumpSpeed: CGFloat = 450.0
    static let jumpDuration: Double = 0.5
    
    // multiplayer stuff
    static let streamingInterval = 0.1 // in seconds

    // node naming
    static let ingredientName = "ingredient"
    static let plateName = "plate"
    static let cookerName = "cooker"
    static let roomName = "room"
    static let slimeName = "slime"
    static let ladderName = "ladder"
    static let stationName = "station"
    static let orderQueueName = "orderQueue"

    // spaceship size and position
    static let spaceshipSize = CGSize(width: 800, height: 800)
    static let gameAreaSize = CGSize(width: 800, height: 800)
    static let spaceshipPosition = CGPoint.zero

    // elements size
    static let slimeSize = CGSize(width: 50, height: 50)
    static var hatSize: CGSize {
        return CGSize(width: slimeSize.width * 0.3, height: slimeSize.height * 0.3)
    }
    static var accessorySize: CGSize {
        return CGSize(width: slimeSize.width * 0.2, height: slimeSize.height * 0.2)
    }
    static var hatOffset: CGPoint {
        return CGPoint(x: 0.175 * slimeSize.width, y: 0.25 * slimeSize.height)
    }
    static var accessoryOffset: CGPoint {
        return CGPoint(x: 0.25 * slimeSize.width, y: -0.05 * slimeSize.height)
    }
    static let hatRotation: CGFloat = 0.35
    static let accessoryRotation: CGFloat = -0.5
    static let plateSize = CGSize(width: 60, height: 60)
    static let ingredientSize = CGSize(width: 50, height: 50)
    static let cookerSize = CGSize(width: 80, height: 80)
    static let ladderSize = CGSize(width: 100, height: 100)
    static let stationSize = CGSize(width: 80, height: 80)
    static let trashBinSize = CGSize(width: 100, height: 100)

    // controller size and position
    static let joystickSize = CGFloat(100)
    static let joystickPosition = CGPoint(x: ScreenSize.width * -0.5 + joystickSize / 2 + 45,
                                          y: ScreenSize.height * -0.5 + joystickSize / 2 + 45)
    static let jumpButtonPosition = CGPoint(x: ScreenSize.width * 0.5 - 130,
                                            y: ScreenSize.height * -0.5 + 45)
    static let interactButtonPosition = CGPoint(x: ScreenSize.width * 0.5 - 75,
                                            y: ScreenSize.height * -0.5 + 100)
    static let backButtonPosition = CGPoint(x: ScreenSize.width * -0.5 + 45,
                                                y: ScreenSize.height * 0.5 + -40)
    static let notificationPosition = CGPoint(x: 0.0, y: ScreenSize.height * -0.5 + 50)

    //UI position
    static let timerPosition = CGPoint(x: ScreenSize.width * -0.5 + 80,
                                       y: ScreenSize.height * 0.5 - 40)
    static let scorePosition = CGPoint(x: ScreenSize.width * -0.5 + 20,
                                       y: ScreenSize.height * -0.5 + 20)
    static let gameOverPrefabSize = CGSize(width: 400, height: 400)
    static let notificationSize = CGSize(width: 300, height: 40)

    // collision bitmask
    static let wallCategoryCollision: UInt32 = 1 << 0

    // category bitmask
    static let plateCategory: UInt32 = 1 << 1
    static let ingredientCategory: UInt32 = 1 << 2
    static let slimeCategory: UInt32 = 1 << 4
    static let ladderCategory: UInt32 = 1 << 5
    static let stationCategory: UInt32 = 1 << 6

    // zPosition list
    static let backgroundZPos = CGFloat(-1)
    static let spaceshipZPos = CGFloat(0)
    static let ladderZPos = CGFloat(1)
    static let stationZPos = CGFloat(2)
    static let mobileItemZPos = CGFloat(3) // possibly +orderZPos or +stationZPos
    static let joystickZPos = CGFloat(4)
    static let buttonZPos = CGFloat(4)
    static let slimeZPos = CGFloat(5)
    static let orderZPos = CGFloat(9)
    static let blackBGOpeningZPos = CGFloat(12)
    static let blackBGEndingZPos = CGFloat(12)
    static let countdownLabelZPos = CGFloat(20)
    static let scoreLabelZPos = CGFloat(20)
    static let readyNodeZPos = CGFloat(20)
    static let endgameZPos = CGFloat(20)
    static let endgameBasenodeZPos = CGFloat(20)

    // gameplay related
    static let defaultOptionalProbability = 0.5
    static let defaultTimeLimitOrder = CGFloat(45)
    static let minNumbersOfOrdersShown = 1
    static let maxNumbersOfOrdersShown = 6
    static let orderComingInterval = [30.0, 26.0, 23.0, 20.0, 20.0]
    static let cookingTimerInterval = 0.05

    //OrderQueue and its components
    static let menuPrefabSize = CGSize(width: 95, height: 95)
    static let menuPrefabColor = UIColor.clear
    static let blackBarPosOQ = CGPoint(x: 25, y: -25)
    static let blackBarSizeOQ = CGSize(width: 35, height: 30)
    static let greenBarAnchorOQ = CGPoint(x: 0, y: 0)
    static let greenBarPositionOQ = CGPoint(x: -15, y: -15)
    static let greenBarSizeOQ = CGSize(width: 30, height: 30)
    static let timerInterval = 1.0

    // general constant
    static let notFound = Int.min
}
