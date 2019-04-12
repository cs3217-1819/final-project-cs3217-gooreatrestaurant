//
//  Plate.swift
//  GooreatRestaurant
//
//  Created by Samuel Henry Kurniawan on 14/3/19.
//  Copyright © 2019 CS3217. All rights reserved.
//

import UIKit
import SpriteKit

class Plate: SKSpriteNode, Codable {
    var food = Food()

    init(inPosition position: CGPoint, withSize size: CGSize = StageConstants.plateSize) {
        let plate = SKTexture(imageNamed: "Plate")
        plate.filteringMode = .nearest
        super.init(texture: plate, color: .clear, size: size)
        self.name = StageConstants.plateName
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.categoryBitMask = StageConstants.plateCategory
        self.physicsBody?.collisionBitMask = StageConstants.wallCategoryCollision
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    enum CodingKeys: String, CodingKey {
        case food
        case position
    }

    required convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let food = try values.decode(Food.self, forKey: .food)
        let position = try values.decode(CGPoint.self, forKey: .position)

        self.init(inPosition: position)
        self.food = food
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(food, forKey: .food)
        try container.encode(position, forKey: .position)
    }
}
