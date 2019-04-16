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

    init() {
        super.init(texture: nil, color: .clear, size: CGSize.zero)
        self.position = CGPoint.zero
        self.name = StageConstants.orderQueueName
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    @objc
    func multiplayerAddRandomOrder() {
        guard let recipe = self.generateRandomRecipe() else { return }
        self.addOrder(ofRecipe: recipe)
        
        if isMultiplayerEnabled {
            multiplayerUpdateSelf()
            sendNotification(withDescription: "someone ordered \(recipe.recipeName), chop chop!")
        }
    }
    
    private func sendNotification(withDescription description: String, withType type: String = NotificationPrefab.NotificationTypes.info.rawValue) {
        let database = GameDB()
        guard let id = self.gameId else { return }
        database.sendNotification(forGameId: id, withDescription: description, withType: type, { }) { (err) in
            print(err.localizedDescription)
        }
    }
    
    func addPossibleRecipe(_ recipe: Recipe) {
        self.possibleRecipes.insert(recipe)
    }

    func initialize() {
        guard !possibleRecipes.isEmpty else {
            return
        }

        newOrderTimer = Timer.scheduledTimer(withTimeInterval: StageConstants.orderComingInterval, repeats: true, block: { (timer) in
            self.isMultiplayerEnabled ? self.multiplayerAddRandomOrder() : self.addRandomOrder()
        })
        
        while recipeOrdered.count < StageConstants.minNumbersOfOrdersShown {
            self.addRandomOrder()
        }
        
        
        if isMultiplayerEnabled { multiplayerUpdateSelf() }
    }
    
    func multiplayerUpdateSelf() {
        let db = GameDB()
        guard let id = gameId else { return }
        db.updateOrderQueue(forGameId: id, withOrderQueue: self, { }) { (err) in
            print(err.localizedDescription)
        }
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
        
        if self.isMultiplayerEnabled {
            self.multiplayerUpdateSelf()
            self.sendNotification(withDescription: "oops! you missed the \(recipe.recipeName) order!", withType: NotificationPrefab.NotificationTypes.warning.rawValue)
        }
    }

    func removeMenuPrefab(inNum: Int) {
        //remove the node image and the list
        nodeOrder[inNum].removeFromParent()
        let node = nodeOrder.remove(at: inNum)
        
        self.scoreToIncrease = calculateScore(timeLeft: node.time)
        if self.isMultiplayerEnabled {
            let db = GameDB()
            guard let id = gameId else { return }
            db.addScore(by: scoreToIncrease, forGameId: id, { }) { (err) in
                print(err.localizedDescription)
            }
        }
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
    }

    required convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let possibleRecipes = try values.decode(Set<Recipe>.self, forKey: .possibleRecipes)
        let recipeOrdered = try values.decode([Recipe].self, forKey: .recipeOrdered)
        let nodeOrder = try values.decode([MenuPrefab].self, forKey: .nodeOrder)

        self.init()
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
