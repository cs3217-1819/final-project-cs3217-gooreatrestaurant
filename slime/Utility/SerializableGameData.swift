//
//  SerializableGameData.swift
//  slime
//
//  Created by Developer on 29/3/19.
//  Copyright © 2019 nus.cs3217.a0143378y. All rights reserved.
//

import Foundation

public class SerializableGameData: Codable {
    public typealias DictString = [String: String]
    public typealias RecipeData = [String: [DictString]]

    public var possibleRecipes: [RecipeData]
    public var trashBin: [String]
    public var table: [String]
    public var storefront: String
    public var plateStorage: [String]
    public var ingredientStorage: [DictString]
    public var oven: [String]
    public var fryingEquipment: [String]
    public var choppingEquipment: [String]
    public var border: [[String]]
    public var blockedArea: [[String]]
    public var ladder: [String]
    public var slimeInitPos: String

    enum LevelDesignKeys: String, CodingKey {
        case possibleRecipes
        case trashBin
        case table
        case storefront
        case plateStorage
        case ingredientStorage
        case oven
        case fryingEquipment
        case choppingEquipment
        case border
        case blockedArea
        case ladder
        case slimeInitPos
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: LevelDesignKeys.self)
        try container.encode(possibleRecipes, forKey: .possibleRecipes)
        try container.encode(trashBin, forKey: .trashBin)
        try container.encode(table, forKey: .table)
        try container.encode(storefront, forKey: .storefront)
        try container.encode(plateStorage, forKey: .plateStorage)
        try container.encode(ingredientStorage, forKey: .ingredientStorage)
        try container.encode(oven, forKey: .oven)
        try container.encode(fryingEquipment, forKey: .fryingEquipment)
        try container.encode(choppingEquipment, forKey: .choppingEquipment)
        try container.encode(border, forKey: .border)
        try container.encode(blockedArea, forKey: .blockedArea)
        try container.encode(ladder, forKey: .ladder)
        try container.encode(slimeInitPos, forKey: .slimeInitPos)
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: LevelDesignKeys.self)
        let possibleRecipes: [RecipeData] = try container.decode([RecipeData].self, forKey: .possibleRecipes)
        let trashBin: [String] = try container.decode([String].self, forKey: .trashBin)
        let table: [String] = try container.decode([String].self, forKey: .table)
        let storefront: String = try container.decode(String.self, forKey: .storefront)
        let plateStorage: [String] = try container.decode([String].self, forKey: .plateStorage)
        let ingredientStorage: [DictString] = try container.decode([DictString].self, forKey: .ingredientStorage)
        let oven: [String] = try container.decode([String].self, forKey: .oven)
        let fryingEquipment: [String] = try container.decode([String].self, forKey: .fryingEquipment)
        let choppingEquipment: [String] = try container.decode([String].self, forKey: .choppingEquipment)
        let border: [[String]] = try container.decode([[String]].self, forKey: .border)
        let blockedArea: [[String]] = try container.decode([[String]].self, forKey: .blockedArea)
        let ladder: [String] = try container.decode([String].self, forKey: .ladder)
        let slimeInitPos: String = try container.decode(String.self, forKey: .slimeInitPos)

        self.possibleRecipes = possibleRecipes
        self.trashBin = trashBin
        self.table = table
        self.storefront = storefront
        self.plateStorage = plateStorage
        self.ingredientStorage = ingredientStorage
        self.oven = oven
        self.fryingEquipment = fryingEquipment
        self.choppingEquipment = choppingEquipment
        self.border = border
        self.blockedArea = blockedArea
        self.ladder = ladder
        self.slimeInitPos = slimeInitPos
    }
}
