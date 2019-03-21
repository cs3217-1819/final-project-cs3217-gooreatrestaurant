//
//  GameScene.swift
//  slime
//
//  Created by Developer on 20/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    let velocityMultiplier: CGFloat = 0.03

    private var slime = SKSpriteNode()
    private var spaceship:SKNode!
    private var slimeWalkingFrames: [SKTexture] = []

    let birdCategory: UInt32 = 1 << 0
    let worldCategory: UInt32 = 1 << 1
    let pipeCategory: UInt32 = 1 << 2
    let scoreCategory: UInt32 = 1 << 3

    enum NodesZPosition: CGFloat {
        case background, joystick
    }

    lazy var background: SKSpriteNode = {
        var sprite = SKSpriteNode(imageNamed: "background-1")
        sprite.position = CGPoint.zero
        sprite.zPosition = -1
        sprite.scaleTo(screenWidthPercentage: 1.0)
        return sprite
    }()

    lazy var analogJoystick: AnalogJoystick = {
        let js = AnalogJoystick(diameter: 100, colors: nil, images: (substrate: #imageLiteral(resourceName: "jSubstrate"), stick: #imageLiteral(resourceName: "jStick")))
        js.position = CGPoint(x: ScreenSize.width * -0.5 + js.radius + 45, y: ScreenSize.height * -0.5 + js.radius + 45)
        js.zPosition = NodesZPosition.joystick.rawValue
        return js
    }()

    lazy var playButton: BDButton = {
        var button = BDButton(imageNamed: "Up", buttonAction: {
            self.slime.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 3))
            })
        button.setScale(0.1)
        button.isEnabled = true
        button.position =  CGPoint(x: ScreenSize.width * 0.5 - 45, y: ScreenSize.height * -0.5 + 45)
        button.zPosition = 4
        return button
    }()

    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        view.showsPhysics = true
        spaceship = SKNode()

        setupNodes()
        setupJoystick()

        self.addChild(spaceship)

        buildSpaceship()
        buildPlayArea()
        buildSlime()
        animateSlime()
    }

    func setupNodes() {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(background)
        addChild(playButton)
    }

    func setupJoystick() {
        addChild(analogJoystick)

        analogJoystick.trackingHandler = { [unowned self] data in
            let originalPos = self.slime.position
            self.slime.position = CGPoint(x: self.slime.position.x + (data.velocity.x * self.velocityMultiplier),
                                          y: self.slime.position.y + (data.velocity.y * self.velocityMultiplier))
            //self.hero.zRotation = data.angular
            var multiplierForDirection: CGFloat
            if originalPos.x < self.slime.position.x {
                multiplierForDirection = -1.0
            } else {
                multiplierForDirection = 1.0
            }
            self.slime.xScale = abs(self.slime.xScale) * multiplierForDirection
        }
    }

    func buildSlime() {
        let slimeAnimatedAtlas = SKTextureAtlas(named: "Slime")
        var walkFrames: [SKTexture] = []

        let numImages = slimeAnimatedAtlas.textureNames.count
        for i in 1...numImages {
            let slimeTextureName = "slime\(i)"
            walkFrames.append(slimeAnimatedAtlas.textureNamed(slimeTextureName))
        }
        slimeWalkingFrames = walkFrames

        let firstFrameTexture = slimeWalkingFrames[0]
        slime = SKSpriteNode(texture: firstFrameTexture)
        slime.position = CGPoint(x: frame.midX, y: frame.midY - 50)
        slime.scaleTo(screenWidthPercentage: 0.03)
        slime.zPosition = 2

        slime.physicsBody = SKPhysicsBody(texture: slimeAnimatedAtlas.textureNamed("slime1"), size: slime.size)
        slime.physicsBody?.isDynamic = true
        slime.physicsBody?.allowsRotation = false

        slime.physicsBody?.categoryBitMask = birdCategory
        slime.physicsBody?.collisionBitMask = worldCategory | pipeCategory
        slime.physicsBody?.contactTestBitMask = worldCategory | pipeCategory

        addChild(slime)
    }

    func animateSlime() {
        slime.run(SKAction.repeatForever(
            SKAction.animate(with: slimeWalkingFrames,
                             timePerFrame: 0.2,
                             resize: false,
                             restore: true)),
                  withKey:"walkingInPlaceSlime")
        slime.scaleTo(screenWidthPercentage: 0.03)
    }

    func buildSpaceship() {
        let spaceshipBody = SKTexture(imageNamed: "SpaceshipMAIN")
        spaceshipBody.filteringMode = .nearest // shorter form for SKTextureFilteringMode.Nearest
        spaceship = SKSpriteNode(texture: spaceshipBody)
        spaceship.position = CGPoint.zero
        spaceship.setScale(0.4)
        spaceship.zPosition = 0
        addChild(spaceship)
    }

    func buildPlayArea() {
        let spaceshipArea = SKTexture(imageNamed: "Area")
        spaceshipArea.filteringMode = .nearest // shorter form for SKTextureFilteringMode.Nearest
        spaceship = SKSpriteNode(texture: spaceshipArea)
        spaceship.position = CGPoint(x: 0, y: 0)
        spaceship.setScale(0.4)
        spaceship.zPosition = 1
        addChild(spaceship)


        // create the ground
        let spaceshipBorder = SKNode()
        spaceshipBorder.position = CGPoint(x: 0, y: 0)
        var physicsBorderCoord = [CGPoint(x: -115, y: 125),
                                  CGPoint(x: -115, y: 70),
                                  CGPoint(x: -165, y: 70),
                                  CGPoint(x: -165, y: 0),
                                  CGPoint(x: -115, y: 0),
                                  CGPoint(x: -115, y: -10),
                                  CGPoint(x: -145, y: -10),
                                  CGPoint(x: -145, y: -75),
                                  CGPoint(x: -85, y: -75),
                                  CGPoint(x: -85, y: -160),
                                  CGPoint(x: 20, y: -160),
                                  CGPoint(x: 20, y: -140),
                                  CGPoint(x: 55, y: -140),
                                  CGPoint(x: 55, y: -160),
                                  CGPoint(x: 120, y: -160)]
        var secondSetCoord = [CGPoint(x: 120, y: -80),
                              CGPoint(x: 55, y: -80),
                              CGPoint(x: 55, y: -100),
                              CGPoint(x: 20, y: -100),
                              CGPoint(x: 20, y: -80),
                              CGPoint(x: -35, y: -80),
                              CGPoint(x: -35, y: -75),
                              CGPoint(x: 25, y: -75),
                              CGPoint(x: 25, y: -50),
                              CGPoint(x: 160, y: -50),
                              CGPoint(x: 160, y: 50),
                              CGPoint(x: 110, y: 50)]
        var thirdSetCoord = [CGPoint(x: 110, y: 95),
                             CGPoint(x: 90, y: 95),
                             CGPoint(x: 90, y: 125)]
        physicsBorderCoord += secondSetCoord
        physicsBorderCoord += thirdSetCoord
        let ground = SKShapeNode(points: &physicsBorderCoord, count: physicsBorderCoord.count)

        var middleSetCoord = [CGPoint(x: -40, y: -10),
                              CGPoint(x: 10, y: -10),
                              CGPoint(x: 10, y: 10),
                              CGPoint(x: 55, y: 10),
                              CGPoint(x: 55, y: 55),
                              CGPoint(x: -20, y: 55),
                              CGPoint(x: -20, y: -5),
                              CGPoint(x: -40, y: -5)]
        let mid = SKShapeNode(points: &middleSetCoord, count: middleSetCoord.count)
        let spaceshipBorder2 = SKNode()
        spaceshipBorder2.position = CGPoint(x: 0, y: 0)
        spaceshipBorder2.physicsBody = SKPhysicsBody(edgeLoopFrom: mid.path!)
        spaceshipBorder2.physicsBody?.categoryBitMask = worldCategory
        spaceshipBorder2.physicsBody?.isDynamic = false
        self.addChild(spaceshipBorder2)

        let wallNode = SKShapeNode()
        wallNode.physicsBody = SKPhysicsBody(edgeLoopFrom: ground.path!)
        wallNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY)

        spaceshipBorder.physicsBody = wallNode.physicsBody
        spaceshipBorder.physicsBody?.categoryBitMask = worldCategory
        spaceshipBorder.physicsBody?.isDynamic = false
        self.addChild(spaceshipBorder)
    }
}
