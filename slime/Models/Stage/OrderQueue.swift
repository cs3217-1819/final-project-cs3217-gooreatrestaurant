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
    var possibleRecipes: Set<RecipeTemplate> = []
    var recipeOrdered: [Recipe] = []
    var newOrderTimer: Timer = Timer()
    var nodeOrder: [MenuPrefab] = []
    var interval: Double
    
    // for multiplayer
    var isMultiplayerEnabled = false
    var gameId: String?
    var orderQueueInvalidated: Bool = false
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

    init(interval: Double) {
        self.interval = interval
        super.init(texture: nil, color: .clear, size: CGSize.zero)
        self.position = CGPoint.zero
        self.name = StageConstants.orderQueueName
        self.zPosition = StageConstants.orderZPos
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addPossibleTemplate(_ template: RecipeTemplate) {
        self.possibleRecipes.insert(template)
        RecipeBook.allPossibleRecipes.insert(template)
    }

    // For the new order timer
    private func generateTimer() {
        newOrderTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false, block: { _ in
            if (self.orderQueueInvalidated) {
                return
            }
            self.isMultiplayerEnabled ? self.multiplayerAddRandomOrder() : self.addRandomOrder()
            
            self.generateTimer()
        })
    }

    // generate timer, then the first few orders
    func initialize() {
        guard !possibleRecipes.isEmpty else {
            return
        }

        generateTimer()
        
        while recipeOrdered.count < StageConstants.minNumbersOfOrdersShown {
            self.addRandomOrder()
        }
        
        
        if isMultiplayerEnabled { multiplayerUpdateSelf() }
    }

    func setMultiplayer(withGameId id: String) {
        self.isMultiplayerEnabled = true
        self.gameId = id
    }

    private func addOrderFronDecoder(ofRecipe recipe: Recipe, andPrefab prefab: MenuPrefab) {
        recipeOrdered.append(recipe)
        nodeOrder.append(prefab)
        self.addChild(prefab)
    }

    // for UI in the right side
    func generateMenu(ofRecipe recipe: Recipe) {
        let menuObj = MenuPrefab(color: StageConstants.menuPrefabColor, size: StageConstants.menuPrefabSize)
        menuObj.addRecipe(recipe, inPosition: positionings[recipeOrdered.count - 1])
        nodeOrder.append(menuObj)
        self.addChild(menuObj)
    }

    // general function to add order
    func addOrder(ofRecipe recipe: Recipe) {
        guard self.recipeOrdered.count < StageConstants.maxNumbersOfOrdersShown else {
            return
        }
        recipeOrdered.append(recipe)
        generateMenu(ofRecipe: recipe)
    }

    func generateRandomRecipe() -> Recipe? {
        return self.possibleRecipes.randomElement()?.generateRecipe()
    }

    // generate random recipe, then add order of that recipe
    @objc
    func addRandomOrder() {
        guard let randomRecipe = self.generateRandomRecipe() else {
            return
        }
        self.addOrder(ofRecipe: randomRecipe)
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
            self.isMultiplayerEnabled ? self.multiplayerAddRandomOrder() : self.addRandomOrder()
        }
        return true
    }

    // The view will call this function if there is timeout of an order
    func orderTimeOut(ofRecipe recipe: Recipe) {
        if orderQueueInvalidated { return }
        guard let matchedOrder = recipeOrdered.firstIndex(where: { $0 == recipe }) else {
            return
        }
        AudioMaster.instance.playSFX(name: "order-missed")
        recipeOrdered.remove(at: matchedOrder)
        removeMenuPrefab(inNum: matchedOrder)
        if recipeOrdered.count < StageConstants.minNumbersOfOrdersShown {
            self.isMultiplayerEnabled ? self.multiplayerAddRandomOrder() : self.addRandomOrder()
            return
        }
        self.setMultiplayerTimeout(forRecipe: recipe)
    }

    private func removeMenuPrefab(inNum: Int) {
        //remove the node image and the list
        nodeOrder[inNum].removeFromParent()
        let node = nodeOrder.remove(at: inNum)
        self.scoreToIncrease = calculateScore(timeLeft: node.time)
        
        self.multiplayerAddScore(by: scoreToIncrease)
        
        guard nodeOrder.count > 0 else {
            return
        }
        //update positionings
        for i in 1...nodeOrder.count {
            nodeOrder[i-1].position = positionings[i-1]
        }
    }

    func calculateScore(timeLeft: CGFloat) -> Int {
        let score = 20 + Int(timeLeft / StageConstants.defaultTimeLimitOrder * 100)
        return score
    }

    // For multiplayer
    enum CodingKeys: String, CodingKey {
        case possibleRecipes
        case recipeOrdered
        case nodeOrder
    }

    required convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let possibleRecipes = try values.decode(Set<RecipeTemplate>.self, forKey: .possibleRecipes)
        let recipeOrdered = try values.decode([Recipe].self, forKey: .recipeOrdered)
        let nodeOrder = try values.decode([MenuPrefab].self, forKey: .nodeOrder)
        self.init(interval: StageConstants.orderComingInterval[0])
        self.possibleRecipes = possibleRecipes
        self.recipeOrdered = recipeOrdered
        self.nodeOrder = nodeOrder
        for prefab in nodeOrder {
            self.addChild(prefab)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(possibleRecipes, forKey: .possibleRecipes)
        try container.encode(recipeOrdered, forKey: .recipeOrdered)
        try container.encode(nodeOrder, forKey: .nodeOrder)
    }
}
