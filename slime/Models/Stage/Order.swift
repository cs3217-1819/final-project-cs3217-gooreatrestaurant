//
//  Order.swift
//  GooreatRestaurant
//
//  Created by Samuel Henry Kurniawan on 14/3/19.
//  Copyright © 2019 CS3217. All rights reserved.
//

import UIKit

class Order {
    var timeLimit: CGFloat
    let recipeWanted: Recipe

    init(_ recipe: Recipe, withinTime time: CGFloat) {
        self.timeLimit = time
        self.recipeWanted = recipe
    }
}
