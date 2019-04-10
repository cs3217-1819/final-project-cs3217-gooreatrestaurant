//
//  Order.swift
//  GooreatRestaurant
//
//  Created by Samuel Henry Kurniawan on 14/3/19.
//  Copyright © 2019 CS3217. All rights reserved.
//

import UIKit
import SpriteKit

class OrderQueue: SKSpriteNode {
    var possibleRecipes: Set<Recipe> = []
    var recipeOrdered: [Recipe] = []
    var newOrderTimer: Timer = Timer()
    var nodeOrder: [SKSpriteNode] = []

    var tempNode: SKSpriteNode = SKSpriteNode.init()

    var positionings = [CGPoint(x: ScreenSize.width * 0.5 - 180,
                                y: ScreenSize.height * 0.5 - 40),
                        CGPoint(x: ScreenSize.width * 0.5 - 90,
                                y: ScreenSize.height * 0.5 - 40),
                        CGPoint(x: ScreenSize.width * 0.5 - 180,
                                y: ScreenSize.height * 0.5 - 120),
                        CGPoint(x: ScreenSize.width * 0.5 - 90,
                                y: ScreenSize.height * 0.5 - 120),
                        CGPoint(x: ScreenSize.width * 0.5 - 180,
                                y: ScreenSize.height * 0.5 - 200),
                        CGPoint(x: ScreenSize.width * 0.5 - 90,
                                y: ScreenSize.height * 0.5 - 200)]

    init() {
        super.init(texture: nil, color: .clear, size: CGSize.zero)
        self.position = CGPoint.zero
        self.name = StageConstants.orderQueueName
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func generateMenu(ofRecipe recipe: Recipe) {
        let menuObj = MenuPrefab(color: .clear, size: CGSize(width: 80, height: 80))
        menuObj.addRecipe(recipe, inPosition: positionings[recipeOrdered.count - 1])
        nodeOrder.append(menuObj)
        self.addChild(menuObj)
    }

    func addOrder(ofRecipe recipe: Recipe) {
        guard self.recipeOrdered.count < StageConstants.maxNumbersOfOrdersShown else {
            return
        }
        recipeOrdered.append(recipe)
        generateMenu(ofRecipe: recipe)
    }

    func generateRandomRecipe() -> Recipe? {
        return self.possibleRecipes.randomElement()?.regenerateRecipe()
    }

    @objc
    func addRandomOrder() {
        guard let randomRecipe = self.generateRandomRecipe() else {
            return
        }
        print(randomRecipe.ingredientsNeeded)
        self.addOrder(ofRecipe: randomRecipe)
    }

    func addPossibleRecipe(_ recipe: Recipe) {
        self.possibleRecipes.insert(recipe)
    }

    func initialize() {
        guard !possibleRecipes.isEmpty else {
            return
        }

        while recipeOrdered.count < StageConstants.minNumbersOfOrdersShown {
            self.addRandomOrder()
        }

        newOrderTimer = Timer.scheduledTimer(timeInterval: StageConstants.orderComingInterval,
                                             target: self,
                                             selector: #selector(addRandomOrder),
                                             userInfo: nil,
                                             repeats: true)
    }

    // True if success, false if failed (no corresponding orders)
    func completeOrder(withFood food: Food) -> Bool {
        let ingredientsPrepared = food.ingredientsList

        guard let matchedOrder = recipeOrdered.firstIndex(where: { $0.ingredientsNeeded == ingredientsPrepared }) else {
            return false
        }

        recipeOrdered.remove(at: matchedOrder)
        nodeOrder[matchedOrder].removeFromParent()

        if recipeOrdered.count < StageConstants.minNumbersOfOrdersShown {
            self.addRandomOrder()
        }

        return true
    }

    // The view will call this function if there is timeout of an order
    func orderTimeOut(ofRecipe recipe: Recipe) {
        guard let matchedOrder = recipeOrdered.firstIndex(where: { $0 == recipe }) else {
            return
        }

        recipeOrdered.remove(at: matchedOrder)

        if recipeOrdered.count < StageConstants.minNumbersOfOrdersShown {
            self.addRandomOrder()
        }
    }
}
