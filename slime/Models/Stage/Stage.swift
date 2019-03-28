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

    override func didMove(to view: SKView) {
        view.showsPhysics = true
    }

    override init(size: CGSize = CGSize(width: StageConstants.maxXAxisUnits, height: StageConstants.maxYAxisUnits)) {
        spaceship = Spaceship(inPosition: StageConstants.spaceshipPosition, withSize: StageConstants.spaceshipSize)
        super.init(size: size)
        let background = SKSpriteNode(imageNamed: "background-1")
        background.position = StageConstants.spaceshipPosition
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        background.size = size
        background.scaleTo(screenWidthPercentage: 1.0)
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

    lazy var jumpButton: BDButton = {
        var button = BDButton(imageNamed: "Up", buttonAction: {
            self.slimeToControl?.jump()
            })
        button.setScale(0.1)
        button.isEnabled = true
        button.position = StageConstants.jumpButtonPosition
        button.zPosition = 4
        return button
    }()

    lazy var interactButton: BDButton = {
        var button = BDButton(imageNamed: "Interact", buttonAction: {
            print("TEST")
            })
        button.setScale(0.1)
        button.isEnabled = true
        button.position = StageConstants.interactButtonPosition
        button.zPosition = 4
        return button
    }()

    func setupControl() {
        self.addChild(jumpButton)
        self.addChild(interactButton )
        self.addChild(analogJoystick)

        analogJoystick.trackingHandler = { [unowned self] data in
            if data.velocity.x > 0.0 {
                self.slimeToControl?.moveRight(withSpeed: data.velocity.x)
            } else if data.velocity.x < 0.0 {
                self.slimeToControl?.moveLeft(withSpeed: -data.velocity.x)
            }

            if data.velocity.y > abs(data.velocity.x) {
                self.slimeToControl?.jump()
            }

            if data.velocity.y > 0.0 {
                self.slimeToControl?.moveUp(withSpeed: data.velocity.y)
            } else if data.velocity.y < 0.0 {
                self.slimeToControl?.moveDown(withSpeed: -data.velocity.y)
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

    override func didSimulatePhysics() {
        self.slimeToControl?.resetMovement()
        super.didSimulatePhysics()
    }

    var slimeToControl: Slime? {
        var playerSlime: Slime?

        spaceship.enumerateChildNodes(withName: "slime") {
            node, stop in

            guard let slime = node as? Slime else {
                return
            }

            playerSlime = slime
            stop.initialize(to: true)
        }
        return playerSlime
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("initiation using storyboard is not implemented yet.")
    }
}
