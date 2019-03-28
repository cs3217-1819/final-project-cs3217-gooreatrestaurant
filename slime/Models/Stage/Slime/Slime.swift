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

    var isContactingWithLadder = false
    
    init(inPosition position: CGPoint, withSize size: CGSize = StageConstants.slimeSize) {
        let slimeAnimatedAtlas = SKTextureAtlas(named: "Slime")
        var walkFrames: [SKTexture] = []

        let numImages = slimeAnimatedAtlas.textureNames.count
        for i in 1...numImages {
            let slimeTextureName = "slime\(i)"
            walkFrames.append(slimeAnimatedAtlas.textureNamed(slimeTextureName))
        }

        super.init(texture: walkFrames[0], color: .clear, size: size)

        self.name = StageConstants.slimeName

        self.position = position
        self.zPosition = StageConstants.slimeZPos
        self.physicsBody = SKPhysicsBody(texture: slimeAnimatedAtlas.textureNamed("slime1"), size: size)
        self.physicsBody?.isDynamic = true
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
        self.physicsBody?.contactTestBitMask |= StageConstants.storageCategory

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

    private func takeItem(_ item: SKSpriteNode) {
        item.removeFromParent()
        item.position.x = 0.0
        item.position.y = 0.5 * (self.size.height + item.size.height)
        item.physicsBody = nil
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

    private func takePlate(fromStorage storage: PlateStorage) {
        let plate = storage.takePlate()
        self.takePlate(plate)
    }

    private func takeIngredient(fromContainer container: IngredientContainer) {
        let ingredient = container.takeIngredient()
        self.takeIngredient(ingredient)
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

    func interactWithoutCarryingAnything() {
        var hasInteracted = false
        guard let contactedBodies = self.physicsBody?.allContactedBodies() else {
            return
        }

        for body in contactedBodies where body.node?.name == StageConstants.ingredientName {
            guard let ingredient = body.node as? Ingredient else {
                continue
            }

            hasInteracted = true
            self.takeIngredient(ingredient)
            break
        }

        guard hasInteracted == false else {
            return
        }

        for body in contactedBodies where body.node?.name == StageConstants.plateName {
            guard let plate = body.node as? Plate else {
                continue
            }

            hasInteracted = true
            self.takePlate(plate)
            break
        }

        guard hasInteracted == false else {
            return
        }

        for body in contactedBodies where body.node?.name == StageConstants.ingredientContainerName {
            guard let container = body.node as? IngredientContainer else {
                continue
            }

            hasInteracted = true
            self.takeIngredient(fromContainer: container)
            break
        }

        guard hasInteracted == false else {
            return
        }

        for body in contactedBodies where body.node?.name == StageConstants.plateStorageName {
            guard let storage = body.node as? PlateStorage else {
                continue
            }

            hasInteracted = true
            self.takePlate(fromStorage: storage)
            break
        }
    }

    func interactWhileCarryingIngredient() {
        var hasInteracted = false
        guard let contactedBodies = self.physicsBody?.allContactedBodies() else {
            return
        }

        for body in contactedBodies where body.node?.name == StageConstants.cookerName {
            guard let cooker = body.node as? CookingEquipment else {
                continue
            }

            hasInteracted = true
            self.cook(using: cooker)
            break
        }

        guard hasInteracted == false else {
            return
        }

        for body in contactedBodies where body.node?.name == StageConstants.plateName{
            guard let plate = body.node as? Plate else {
                continue
            }

            let success = self.putIngredient(into: plate)
            guard success == true else {
                continue
            }

            hasInteracted = true
            break
        }
    }

    func interactWhileCarryingPlate() {

    }

    func interact() {
        if !isCarryingSomething {
            interactWithoutCarryingAnything()
        } else if plateCarried != nil {
            interactWhileCarryingPlate()
        } else {
            interactWhileCarryingIngredient()
        }
    }
}
