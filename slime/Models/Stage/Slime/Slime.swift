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

    var player: Player?

    init(inPosition position: CGPoint, withSize size: CGSize = StageConstants.slimeSize) {
        super.init(texture: nil, color: .clear, size: size)

        self.name = StageConstants.slimeName
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

    var itemCarried: MobileItem? {
        if let plate = plateCarried {
            return plate
        }

        if let ingredient = ingredientsCarried {
            return ingredient
        }

        return nil
    }

    var spaceship: Spaceship? {
        guard let node = parent else {
            return nil
        }

        return node as? Spaceship
    }

    var isCarryingSomething: Bool {
        return itemCarried != nil
    }

    func removeItem() {
        self.removeAllChildren()
    }

    func takeItem(_ item: MobileItem?) {
        guard itemCarried == nil else {
            return
        }
        item?.taken(by: self)
    }

    func dropItem() -> MobileItem? {
        guard let item = itemCarried else {
            return nil
        }
        item.dropped(by: self)
        return item
    }

    func interact(onInteractWithStation: @escaping (Station) -> Void, onPickUpItem: @escaping (MobileItem, MobileItem) -> Void, onDropItem: @escaping (MobileItem) -> Void, onInteractWithItem: @escaping (MobileItem) -> Void) {
        guard let contactedBodies = self.physicsBody?.allContactedBodies() else { return }

        for body in contactedBodies {
            guard let node = body.node else {
                continue
            }

            guard let mobileItem = node as? MobileItem else {
                continue
            }

            if mobileItem.ableToInteract(withItem: self.itemCarried) {
                let itemToInteract = self.itemCarried
                itemToInteract?.removeFromParent()

                if let resultingItem = mobileItem.interact(withItem: itemToInteract) as? MobileItem {
                    AudioMaster.instance.playSFX(name: "pickup")
                    self.takeItem(resultingItem)
                    onPickUpItem(mobileItem, resultingItem)
                    return
                }
                
                onInteractWithItem(mobileItem)
                return
            }
        }

        for body in contactedBodies {
            guard let node = body.node else {
                continue
            }

            guard let station = node as? Station else {
                continue
            }

            if station.ableToInteract(withItem: self.itemCarried) {
                let itemToProcess = self.itemCarried
                itemToProcess?.removeFromParent()

                if let itemProcessed = station.interact(withItem: itemToProcess) as? MobileItem {
                    AudioMaster.instance.playSFX(name: "pickup")
                    self.takeItem(itemProcessed)
                }
                
                onInteractWithStation(station)
                return
            }
        }
        
        let item = dropItem()
        guard let droppedItem = item else { return }
        onDropItem(droppedItem)
        return
    }

    func addUser(_ user: Player) {
        self.player = user

        guard let color = self.player?.color else {
            fatalError("Player Color is not set in Slime!")
        }

        let slimeAnimatedAtlas = SKTextureAtlas(named: color.toAtlasName())
        var walkFrames: [SKTexture] = []

        let numImages = slimeAnimatedAtlas.textureNames.count
        for i in 1...numImages {
            let slimeTextureName = "slime\(i)"
            walkFrames.append(slimeAnimatedAtlas.textureNamed(slimeTextureName))
        }

        self.texture = walkFrames[0]

        self.position = position
        self.zPosition = StageConstants.slimeZPos
        self.physicsBody = SKPhysicsBody(texture: slimeAnimatedAtlas.textureNamed("slime1"), size: size)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.collisionBitMask = StageConstants.wallCategoryCollision
        self.physicsBody?.categoryBitMask = StageConstants.slimeCategory
        self.physicsBody?.contactTestBitMask = 0

        self.physicsBody?.contactTestBitMask |= StageConstants.plateCategory
        self.physicsBody?.contactTestBitMask |= StageConstants.ingredientCategory
        self.physicsBody?.contactTestBitMask |= StageConstants.slimeCategory
        self.physicsBody?.contactTestBitMask |= StageConstants.ladderCategory
        self.physicsBody?.contactTestBitMask |= StageConstants.stationCategory

        // animate slime
        self.run(SKAction.repeatForever(
            SKAction.animate(with: walkFrames,
                             timePerFrame: 0.2,
                             resize: false,
                             restore: true)),
                 withKey: "walkingInPlaceSlime")


        let hatNode = SKSpriteNode.init()
        if let hat = CosmeticConstants.hatsDict[player!.hat] {
            if (hat.image != nil) {
                hatNode.texture = SKTexture(image: hat.image!)
                hatNode.size = CGSize(width: 10, height: 10)
                self.addChild(hatNode)
            }
        }

        let accessoryNode = SKSpriteNode.init()
        if let accessory = CosmeticConstants.accessoriesDict[player!.accessory] {
            if (accessory.image != nil) {
                accessoryNode.texture = SKTexture(image: accessory.image!)
                accessoryNode.size = CGSize(width: 10, height: 10)
                self.addChild(accessoryNode)
            }
        }
    }
}
