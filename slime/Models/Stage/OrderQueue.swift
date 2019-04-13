//
//  Order.swift
//  GooreatRestaurant
//
//  Created by Samuel Henry Kurniawan on 14/3/19.
//  Copyright © 2019 CS3217. All rights reserved.
//

import UIKit
import SpriteKit

class OrderQueue: SKSpriteNode, Codable {
    var possibleRecipes: Set<Recipe> = []
    var recipeOrdered: [Recipe] = []
    var newOrderTimer: Timer = Timer()
    var nodeOrder: [MenuPrefab] = []
    
    var isMultiplayer = false

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

    var scoreToIncrease = 0

    init(isMultiplayer: Bool = false) {
        super.init(texture: nil, color: .clear, size: CGSize.zero)
        self.position = CGPoint.zero
        self.name = StageConstants.orderQueueName
        self.isMultiplayer = isMultiplayer
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addOrderFronDecoder(ofRecipe recipe: Recipe, andPrefab prefab: MenuPrefab) {
        recipeOrdered.append(recipe)
        nodeOrder.append(prefab)
        self.addChild(prefab)
    }

    func generateMenu(ofRecipe recipe: Recipe) {
        let menuObj = MenuPrefab(color: StageConstants.menuPrefabColor, size: StageConstants.menuPrefabSize)
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
    
    func multiplayerUpdateSelf() {
//        let db = GameDB()
    }

    // True if success, false if failed (no corresponding orders)
    func completeOrder(withFood food: Food) -> Bool {
        let ingredientsPrepared = food.ingredientsList

        guard let matchedOrder = recipeOrdered.firstIndex(where: { $0.ingredientsNeeded == ingredientsPrepared }) else {
            return false
        }

        recipeOrdered.remove(at: matchedOrder)
        removeMenuPrefab(inNum: matchedOrder)

        if recipeOrdered.count < StageConstants.maxNumbersOfOrdersShown {
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
        removeMenuPrefab(inNum: matchedOrder)

        if recipeOrdered.count < StageConstants.minNumbersOfOrdersShown {
            self.addRandomOrder()
        }
        
        if isMultiplayer { self.multiplayerUpdateSelf() }
    }

    func removeMenuPrefab(inNum: Int) {
        //remove the node image and the list
        nodeOrder[inNum].removeFromParent()
        nodeOrder.remove(at: inNum)
        
        self.scoreToIncrease = calculateScore(timeLeft: nodeOrder[inNum].time)

        //update positionings
        for i in 1...nodeOrder.count {
            nodeOrder[i-1].position = positionings[i-1]
        }
    }

    func calculateScore(timeLeft: CGFloat) -> Int {
        let score = Int(timeLeft / StageConstants.defaultTimeLimitOrder * 100)
        return score
    }

    enum CodingKeys: String, CodingKey {
        case possibleRecipes
        case recipeOrdered
        case nodeOrder
        case nextTimer
    }

    required convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let possibleRecipes = try values.decode(Set<Recipe>.self, forKey: .possibleRecipes)
        let recipeOrdered = try values.decode([Recipe].self, forKey: .recipeOrdered)
        let nodeOrder = try values.decode([MenuPrefab].self, forKey: .nodeOrder)
        let nextTimer = try values.decode(Date.self, forKey: .nextTimer)

        self.init()
        self.possibleRecipes = possibleRecipes
        self.recipeOrdered = recipeOrdered
        self.nodeOrder = nodeOrder
        self.newOrderTimer = Timer(fireAt: nextTimer,
                                   interval: StageConstants.timerInterval,
                                   target: self,
                                   selector: #selector(addRandomOrder),
                                   userInfo: nil,
                                   repeats: true)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(possibleRecipes, forKey: .possibleRecipes)
        try container.encode(recipeOrdered, forKey: .recipeOrdered)
        try container.encode(nodeOrder, forKey: .nodeOrder)
        try container.encode(newOrderTimer.fireDate, forKey: .nextTimer)
    }
}
