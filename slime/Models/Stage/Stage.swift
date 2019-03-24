//
//  Stage.swift
//  GooreatRestaurant
//
//  Created by Samuel Henry Kurniawan on 14/3/19.
//  Copyright © 2019 CS3217. All rights reserved.
//

import UIKit
import SpriteKit

class Stage: SKScene {
    var spaceship: Spaceship
    var orders: [Order] = []

    // RI: the players are unique
    var players: [Player] = []

    override init(size: CGSize = CGSize(width: StageConstants.maxXAxisUnits, height: StageConstants.maxYAxisUnits)) {
        spaceship = Spaceship(inPosition: StageConstants.spaceshipPosition, withSize: StageConstants.spaceshipSize)
        super.init(size: size)

        let background = SKSpriteNode(imageNamed: "background-1")
        background.position = StageConstants.spaceshipPosition
        background.size = size
        background.zPosition = -1
        self.addChild(background)

        self.addChild(spaceship)
        setupControl()
    }

    lazy var analogJoystick: AnalogJoystick = {
        let js = AnalogJoystick(diameter: StageConstants.joystickSize,
                                colors: nil,
                                images: (substrate: #imageLiteral(resourceName: "jSubstrate"),
                                stick: #imageLiteral(resourceName: "jStick")))
        js.position = StageConstants.joystickPosition
        js.zPosition = 1
        return js
    }()

    lazy var playButton: BDButton = {
        var button = BDButton(imageNamed: "Up", buttonAction: {
            self.slimeToControl?.jump()
            })
        button.setScale(1)
        button.isEnabled = true
        button.position = StageConstants.jumpButtonPosition
        button.zPosition = 4
        return button
    }()

    func setupControl() {
        self.addChild(playButton)
        self.addChild(analogJoystick)

        analogJoystick.trackingHandler = { [unowned self] data in
            if data.velocity.x > 0.0 {
                self.slimeToControl?.moveRight()
            } else if data.velocity.x < 0.0 {
                self.slimeToControl?.moveLeft()
            }

            if data.velocity.y > 0.0 {
                self.slimeToControl?.jump()
            }
        }
    }

    // if the player is already in the list, will do nothing
    func addPlayer(_ player: Player) {
        if !players.contains(player) && players.count < StageConstants.maxPlayer {
            players.append(player)
        }
    }

    // if the player is not found, will do nothing
    func removePlayer(_ player: Player) {
        players.removeAll { $0 == player }
    }

    var slimeToControl: Slime? {
        guard spaceship.slimes.count > 0 else {
            return nil
        }
        return spaceship.slimes[0]
    }

    override func didEvaluateActions() {
        spaceship.setItemsMovement()

        super.didEvaluateActions()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("initiation using storyboard is not implemented yet.")
    }
}
