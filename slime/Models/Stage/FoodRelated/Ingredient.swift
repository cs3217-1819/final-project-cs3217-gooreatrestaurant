//
//  Ingredient.swift
//  GooreatRestaurant
//
//  Created by Samuel Henry Kurniawan on 14/3/19.
//  Copyright © 2019 CS3217. All rights reserved.
//

import UIKit
import SpriteKit

class Ingredient: SKSpriteNode, Codable {
    var type: IngredientType
    var processed: [CookingType] = []

    var currentProcessing: CookingType?
    var processingProgress = 0.0

    var blackBar = SKSpriteNode(imageNamed: "Black bar")
    var greenBar = SKSpriteNode(imageNamed: "Green bar")

    init(type: IngredientType,
         size: CGSize = StageConstants.ingredientSize,
         inPosition position: CGPoint = CGPoint.zero) {

        self.type = type

        let ingredientsAtlas = SKTextureAtlas(named: "Ingredients")
        var texture: SKTexture = SKTexture.init()
        texture = ingredientsAtlas.textureNamed(type.rawValue)
        super.init(texture: texture, color: .clear, size: size)

        self.name = StageConstants.ingredientName
        self.position = position

        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.categoryBitMask = StageConstants.ingredientCategory
        self.physicsBody?.collisionBitMask = StageConstants.wallCategoryCollision

        setupBars()
    }

    private func setupBars() {
        blackBar.removeFromParent()
        greenBar.removeFromParent()

        blackBar = SKSpriteNode(imageNamed: "Black bar")
        blackBar.setScale(0)

        greenBar = SKSpriteNode(imageNamed: "Green bar")
        greenBar.anchorPoint = CGPoint(x: 0, y: 0)
        greenBar.position = CGPoint(x: -250, y: -250)
        greenBar.setScale(0)

        blackBar.addChild(greenBar)
        self.addChild(blackBar)
    }

    // Progress 100 denotes that cooking will be done
    func cook(by method: CookingType, withProgress progress: Double = 100.0) {
        guard currentProcessing == nil || currentProcessing == method else {
            return
        }

        // to prevent overcook trauma because of misclick when tapping repeatedly
        guard processed.last != method else {
            return
        }

        currentProcessing = method
        processingProgress += progress

        blackBar.zRotation = -1.5708
        blackBar.setScale(0.1)

        if processingProgress >= 100.0 {
            setupBars()

            let ingredientsAtlas = SKTextureAtlas(named: "ProcessedIngredients")
            var texture: SKTexture = SKTexture.init()
            texture = ingredientsAtlas.textureNamed(self.type.rawValue)
            self.texture = texture

            currentProcessing = nil
            processingProgress = 0.0
            processed.append(method)
        } else {
            greenBar.setScale(1)
            greenBar.yScale = CGFloat(processingProgress / 100.0) * greenBar.yScale
            //temp removal of texture
            self.texture = nil
        }
    }

    func ruin() {
        self.type = .junk
        self.processed = []
    }

    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.type)
        hasher.combine(self.processed)
        return hasher.finalize()
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Ingredient else {
            return false
        }

        return self.type == other.type && self.processed == other.processed
    }

    enum CodingKeys: String, CodingKey {
        case type
        case processed
        case currentProcessing
        case processingProgress
        case position
    }

    required convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let type = try values.decode(IngredientType.self, forKey: .type)
        let processed = try values.decode([CookingType].self, forKey: .processed)
        let currentProcessing = try values.decode(CookingType.self, forKey: .currentProcessing)
        let processingProgress = try values.decode(Double.self, forKey: .processingProgress)
        let position = try values.decode(CGPoint.self, forKey: .position)

        self.init(type: type, inPosition: position)
        for processing in processed { self.cook(by: processing) }
        self.cook(by: currentProcessing, withProgress: processingProgress)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(type, forKey: .type)
        try container.encode(processed, forKey: .processed)
        try container.encode(currentProcessing, forKey: .currentProcessing)
        try container.encode(processingProgress, forKey: .processingProgress)
        try container.encode(position, forKey: .position)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
