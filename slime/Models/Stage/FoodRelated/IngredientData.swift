//
//  IngredientData.swift
//  slime
//
//  Created by Samuel Henry Kurniawan on 1/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

struct IngredientData: Hashable {
    let type: IngredientType
    let processed: CookingType

    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(processed)
    }
}
