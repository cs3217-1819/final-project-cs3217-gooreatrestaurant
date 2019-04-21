//
//  RecipeBook.swift
//  slime
//
//  Created by Samuel Henry Kurniawan on 21/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class RecipeBook: NSObject {
    static var allPossibleRecipes: Set<RecipeTemplate> = []

    static func checkFoodName(ofFood food: Food) -> String? {
        for template in RecipeBook.allPossibleRecipes {
            if template.possibleConsists(of: food) {
                return template.recipeName
            }
        }
        return nil
    }
}
