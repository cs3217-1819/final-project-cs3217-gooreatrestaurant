//
//  SerializableGameData.swift
//  slime
//
//  Created by Developer on 29/3/19.
//  Copyright © 2019 nus.cs3217.a0143378y. All rights reserved.
//

import Foundation

public class SerializableGameData: Codable {
    public var border: [String]
    public var blockedArea: [String]
    public var ladder: [String]
    public var slimeInitPos: String

    enum LevelDesignKeys: String, CodingKey {
        case border
        case blockedArea
        case ladder
        case slimeInitPos
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: LevelDesignKeys.self)
        try container.encode(border, forKey: .border)
        try container.encode(blockedArea, forKey: .blockedArea)
        try container.encode(ladder, forKey: .ladder)
        try container.encode(slimeInitPos, forKey: .slimeInitPos)
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: LevelDesignKeys.self)
        let border: [String] = try container.decode([String].self, forKey: .border)
        let blockedArea: [String] = try container.decode([String].self, forKey: .blockedArea)
        let ladder: [String] = try container.decode([String].self, forKey: .ladder)
        let slimeInitPos: String = try container.decode(String.self, forKey: .slimeInitPos)
        self.border = border
        self.blockedArea = blockedArea
        self.ladder = ladder
        self.slimeInitPos = slimeInitPos
    }
}
