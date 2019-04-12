//
//  CosmeticConstants.swift
//  slime
//
//  Created by Gabriel Tan on 12/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

enum CosmeticConstants {
    static let hatsDict: [String: Cosmetic] = CosmeticConstants.hatsList
        .reduce(into: [String: Cosmetic](), { dict, entry in
            dict[entry.name] = entry
        })
    static let accessoriesDict: [String: Cosmetic] = CosmeticConstants.accessoriesList
        .reduce(into: [String: Cosmetic](), { dict, entry in
            dict[entry.name] = entry
        })
    static let hatsList = [
        Cosmetic("none", nil),
        Cosmetic("birthday", "hat-birthday"),
        Cosmetic("chef", "hat-chef"),
        Cosmetic("grad", "hat-grad-cap"),
        Cosmetic("pamela", "hat-pamela"),
        Cosmetic("santa", "hat-santa"),
        Cosmetic("sombrero", "hat-sombrero"),
        Cosmetic("witch", "hat-witch"),
        Cosmetic("top", "hat-top")
    ]
    
    static let accessoriesList = [
        Cosmetic("none", nil),
        Cosmetic("heart", "acc-heart"),
        Cosmetic("earrings", "acc-earrings"),
        Cosmetic("airpods", "acc-airpods"),
        Cosmetic("flag", "acc-flag"),
        Cosmetic("poker", "acc-poker"),
        Cosmetic("star", "acc-star"),
        Cosmetic("spatula", "acc-spatula"),
        Cosmetic("plus", "acc-plus")
    ]
    
    static func getBases(initial: SlimeColor) -> Wardrobe {
        let list = SlimeColor.allCases.map { color in
            return Cosmetic(color.toString(), color.getImage())
        }
        return Wardrobe(withActiveCosmetic: initial.toString(),
                        cosmetics: list)
    }
    
    static func getHats() -> Wardrobe {
        return Wardrobe(withActiveCosmetic: "none",
                        cosmetics: CosmeticConstants.hatsList)
    }
    
    static func getAccessories() -> Wardrobe {
        return Wardrobe(withActiveCosmetic: "none",
                        cosmetics: CosmeticConstants.accessoriesList)
    }
}
