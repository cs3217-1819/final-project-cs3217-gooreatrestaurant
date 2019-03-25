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

    let spaceship: Spaceship

    var ingredientsCarried: Ingredient?
    var plateCarried: Plate?

    init(inPosition position: CGPoint, withSize size: CGSize = StageConstants.slimeSize, andParents ship: Spaceship) {
        self.spaceship = ship

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
        self.plateCarried = plate
    }

    private func takeIngredient(_ ingredient: Ingredient) {
        guard !self.isCarryingSomething else {
            return
        }

        self.takeItem(ingredient)
        self.ingredientsCarried = ingredient
    }

    private func cook(using equipment: CookingEquipment) {
        guard let ingredient = self.ingredientsCarried else {
            return
        }

        ingredient.cook(using: equipment)
    }

    private func putIngredient(into plate: Plate) -> Bool {
        guard let ingredient = self.ingredientsCarried else {
            return false
        }

        // it will continue if it successfully put
        guard plate.putIngredient(ingredient) == true else {
            return false
        }

        ingredient.removeFromParent()
        ingredientsCarried = nil
        return true
    }

    func interact() {
        var hasInteracted = false
        if !self.isCarryingSomething {

            for ingredient in spaceship.ingredientsOnFloor {
                if self.frame.intersects(ingredient.frame) {
                    self.takeIngredient(ingredient)
                    spaceship.ingredientsOnFloor.removeAll(where: { $0 == ingredient })
                    hasInteracted = true
                    break
                }
            }

            guard hasInteracted == false else {
                return
            }

            for plate in spaceship.platesOnFloor {
                if self.frame.intersects(plate.frame) {
                    self.takePlate(plate)
                    spaceship.platesOnFloor.removeAll(where: { $0 == plate })
                    hasInteracted = true
                    break
                }
            }

        } else if self.ingredientsCarried != nil {

            for cooker in spaceship.cookingEquipments {
                if self.frame.intersects(cooker.frame) {
                    self.cook(using: cooker)
                    hasInteracted = false
                    break
                }
            }

            guard hasInteracted == false else {
                return
            }

            for plate in spaceship.platesOnFloor {
                var success = false
                if self.frame.intersects(plate.frame) {
                    success = self.putIngredient(into: plate)
                }
                if success {
                    hasInteracted = true
                    break
                }
            }
        }
    }
}
