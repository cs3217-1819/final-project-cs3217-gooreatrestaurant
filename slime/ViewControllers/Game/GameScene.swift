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

    let slimeCategory: UInt32 = 1 << 0
    let worldCategory: UInt32 = 1 << 1
    let interactableObjCategory: UInt32 = 1 << 2
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

        slime.physicsBody?.categoryBitMask = slimeCategory
        slime.physicsBody?.collisionBitMask = worldCategory | interactableObjCategory
        slime.physicsBody?.contactTestBitMask = worldCategory | interactableObjCategory

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

        var coordArray: [String] = []
        var gameAreaCoord: [CGPoint] = []
        var unaccessibleAreaCoord: [CGPoint] = []
        guard let path = Bundle.main.path(forResource: "LevelDesign", ofType: "plist")  else {
            print("Error loading path")
            return
        }

        let contents = NSDictionary(contentsOfFile: path)
        coordArray = contents?.object(forKey: "Level 1") as! [String]
        for item in coordArray {
            gameAreaCoord.append(NSCoder.cgPoint(for: item))
        }

        coordArray = contents?.object(forKey: "Level1UnaccessibleArea") as! [String]
        for item in coordArray {
            unaccessibleAreaCoord.append(NSCoder.cgPoint(for: item))
        }

        let spaceshipBorder = SKNode()
        spaceshipBorder.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        let ground = SKShapeNode(points: &gameAreaCoord, count: gameAreaCoord.count)
        let blockedArea = SKShapeNode(points: &unaccessibleAreaCoord, count: unaccessibleAreaCoord.count)
        spaceshipBorder.physicsBody = SKPhysicsBody(edgeLoopFrom: ground.path!)
        spaceshipBorder.physicsBody?.categoryBitMask = worldCategory
        spaceshipBorder.physicsBody?.isDynamic = false
        self.addChild(spaceshipBorder)

        let blockedAreaBorder = SKNode()
        blockedAreaBorder.position = CGPoint(x: 0, y: 0)
        blockedAreaBorder.physicsBody = SKPhysicsBody(edgeLoopFrom: blockedArea.path!)
        blockedAreaBorder.physicsBody?.categoryBitMask = worldCategory
        blockedAreaBorder.physicsBody?.isDynamic = false
        self.addChild(blockedAreaBorder)
    }
}
