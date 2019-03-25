//
//  Slime.swift
//  GooreatRestaurant
//
//  Created by Samuel Henry Kurniawan on 14/3/19.
//  Copyright © 2019 CS3217. All rights reserved.
//

import UIKit
import SpriteKit

class Slime: SKSpriteNode {

    init(inPosition position: CGPoint, withSize size: CGSize = StageConstants.slimeSize) {
        let slimeAnimatedAtlas = SKTextureAtlas(named: "Slime")
        var walkFrames: [SKTexture] = []

        let numImages = slimeAnimatedAtlas.textureNames.count
        for i in 1...numImages {
            let slimeTextureName = "slime\(i)"
            walkFrames.append(slimeAnimatedAtlas.textureNamed(slimeTextureName))
        }

        super.init(texture: walkFrames[0], color: .clear, size: size)
        self.position = position
        self.zPosition = 2
        self.physicsBody = SKPhysicsBody(texture: slimeAnimatedAtlas.textureNamed("slime1"), size: size)
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.collisionBitMask = StageConstants.wallCategoryCollision
        self.physicsBody?.categoryBitMask = StageConstants.slimeCategory
        self.physicsBody?.contactTestBitMask = 0

        self.physicsBody?.contactTestBitMask |= StageConstants.cookerCategory
        self.physicsBody?.contactTestBitMask |= StageConstants.plateCategory
        self.physicsBody?.contactTestBitMask |= StageConstants.ingredientCategory
        self.physicsBody?.contactTestBitMask |= StageConstants.tableCategory
        self.physicsBody?.contactTestBitMask |= StageConstants.slimeCategory
        self.physicsBody?.contactTestBitMask |= StageConstants.ladderCategory

        // animate slime
        self.run(SKAction.repeatForever(
            SKAction.animate(with: walkFrames,
                             timePerFrame: 0.2,
                             resize: false,
                             restore: true)),
                 withKey: "walkingInPlaceSlime")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("initiation using storyboard is not implemented yet.")
    }


    var plateCarried: Plate? {
        guard let node = childNode(withName: "plate") else {
            return nil
        }

        return node as? Plate
    }

    var ingredientsCarried: Ingredient? {
        guard let node = childNode(withName: "ingredient") else {
            return nil
        }

        return node as? Ingredient
    }

    var spaceship: Spaceship? {
        guard let node = parent else {
            return nil
        }

        return node as? Spaceship
    }

    var isCarryingSomething: Bool {
        return ingredientsCarried != nil || plateCarried != nil
    }

    func moveLeft(withSpeed speed: CGFloat) {
        self.physicsBody?.velocity.dx = -speed * StageConstants.speedMultiplier
        self.xScale = abs(self.xScale)
    }

    func jump() {
        guard let physicsBody = self.physicsBody else {
            return
        }

        if physicsBody.velocity.dy == 0.0 {
            physicsBody.applyImpulse(CGVector(dx: 0.0, dy: StageConstants.jumpSpeed))
        }

    }

    func moveRight(withSpeed speed: CGFloat) {
        self.physicsBody?.velocity.dx = speed * StageConstants.speedMultiplier
        self.xScale = -abs(self.xScale)
    }

    private func takeItem(_ item: SKSpriteNode) {
        item.removeFromParent()
        item.position.x = 0.0
        item.position.y = 0.5 * (self.size.height + item.size.height)
        self.addChild(item)
    }

    private func takePlate(_ plate: Plate) {
        guard !self.isCarryingSomething else {
            return
        }
        self.takeItem(plate)
    }

    private func takeIngredient(_ ingredient: Ingredient) {
        guard !self.isCarryingSomething else {
            return
        }

        self.takeItem(ingredient)
    }

    private func cook(using equipment: CookingEquipment) {
        guard let ingredient = self.ingredientsCarried else {
            return
        }

        ingredient.cook(using: equipment)
    }

    // this Bool is success/fail
    private func putIngredient(into plate: Plate) -> Bool {
        guard let ingredient = self.ingredientsCarried else {
            return false
        }

        // it will continue if it successfully put
        guard plate.putIngredient(ingredient) == true else {
            return false
        }

        ingredient.removeFromParent()
        return true
    }

    func interact() {
    }
}
