//
//  Stage.swift
//  GooreatRestaurant
//
//  Created by Samuel Henry Kurniawan on 14/3/19.
//  Copyright © 2019 CS3217. All rights reserved.
//

import UIKit
import SpriteKit

class Stage: SKScene {
    typealias DictString = [String: String]
    typealias RecipeData = [String: [DictString]]

    var spaceship: Spaceship
    var orders: [Order] = []
    var possibleRecipes: Set<Recipe> = []

    // RI: the players are unique
    var players: [Player] = []

    override func didMove(to view: SKView) {
        view.showsPhysics = true
    }

    override init(size: CGSize = CGSize(width: StageConstants.maxXAxisUnits, height: StageConstants.maxYAxisUnits)) {
        spaceship = Spaceship(inPosition: StageConstants.spaceshipPosition, withSize: StageConstants.spaceshipSize)
        super.init(size: size)
        let background = SKSpriteNode(imageNamed: "background-1")
        background.position = StageConstants.spaceshipPosition
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        background.size = size
        background.scaleTo(screenWidthPercentage: 1.0)
        background.zPosition = StageConstants.backgroundZPos
        self.addChild(background)
        self.addChild(spaceship)
        setupControl()
    }

    func generateLevel(inLevel levelName: String) {
        if let levelDesignURL = Bundle.main.url(forResource: levelName, withExtension: "plist") {
            do {
                let data = try? Data(contentsOf: levelDesignURL)
                let decoder = PropertyListDecoder()
                let value = try decoder.decode(SerializableGameData.self, from: data!)
                spaceship.addRoom()
                spaceship.addSlime(inPosition: value.slimeInitPos)
                spaceship.addWall(inCoord: value.border)
                spaceship.addWall(inCoord: value.blockedArea)
                spaceship.addLadder(inPositions: value.ladder)
                spaceship.addChoppingEquipment(inPositions: value.choppingEquipment)
                spaceship.addFryingEquipment(inPositions: value.fryingEquipment)
                spaceship.addOven(inPositions: value.oven)
                spaceship.addPlateStorage(inPositions: value.plateStorage)
                spaceship.addStoreFront(inPosition: value.storefront)
                spaceship.addTable(inPositions: value.table)
                spaceship.addTrashBin(inPositions: value.trashBin)

                var ingredientStorageData: [(type: String, position: String)] = []
                for data in value.ingredientStorage {
                    guard let type = data["type"] else {
                        continue
                    }
                    guard let pos = data["position"] else {
                        continue
                    }
                    ingredientStorageData.append((type: type, position: pos))
                }
                spaceship.addIngredientStorage(withDetails: ingredientStorageData)

                self.initializeOrders(withData: value.possibleRecipes)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    private func getIngredientData(fromDictionaryData data: [String: String]) -> IngredientData? {
        guard let type = data["type"] else {
            return nil
        }

        guard let ingredientEnum = Int(type) else {
            return nil
        }

        guard let ingredientType = IngredientType(rawValue: ingredientEnum) else {
            return nil
        }

        guard let processing = data["processing"] else {
            return nil
        }

        guard let processingEnum = Int(processing) else {
            return nil
        }

        guard let processingType = CookingType(rawValue: processingEnum) else {
            return nil
        }

        let ingredientData = IngredientData(type: ingredientType, processed: processingType)
        return ingredientData
    }

    func initializeOrders(withData data: [RecipeData]) {
        for datum in data {
            var compulsoryIngredients: [IngredientData] = []
            var optionalIngredients: [(item: IngredientData, probability: Double)] = []
            for ingredientRequirement in datum["compulsoryIngredients"] ?? [] {
                guard let ingredientData = getIngredientData(fromDictionaryData: ingredientRequirement) else {
                    continue
                }
                compulsoryIngredients.append(ingredientData)
            }

            for ingredientRequirement in datum["optionalIngredients"] ?? [] {
                guard let ingredientData = getIngredientData(fromDictionaryData: ingredientRequirement) else {
                    continue
                }

                guard let probabilityString = ingredientRequirement["probability"] else {
                    continue
                }

                guard let probability = Double(probabilityString) else {
                    continue
                }

                optionalIngredients.append((item: ingredientData, probability: probability))
            }
            let recipe = Recipe(withCompulsoryIngredients: compulsoryIngredients,
                                withOptionalIngredients: optionalIngredients)
            _ = possibleRecipes.insert(recipe)
        }

        guard !possibleRecipes.isEmpty else {
            return
        }

        while orders.count < StageConstants.numbersOfOrdersShown {
            self.addRandomOrder()
        }
    }

    lazy var analogJoystick: AnalogJoystick = {
        let js = AnalogJoystick(diameter: StageConstants.joystickSize,
                                colors: nil,
                                images: (substrate: #imageLiteral(resourceName: "jSubstrate"),
                                stick: #imageLiteral(resourceName: "jStick")))
        js.position = StageConstants.joystickPosition
        js.zPosition = StageConstants.joystickZPos
        return js
    }()

    lazy var jumpButton: BDButton = {
        var button = BDButton(imageNamed: "Up", buttonAction: {
            self.slimeToControl?.jump()
            })
        button.setScale(0.1)
        button.isEnabled = true
        button.position = StageConstants.jumpButtonPosition
        button.zPosition = StageConstants.buttonZPos
        return button
    }()

    lazy var interactButton: BDButton = {
        var button = BDButton(imageNamed: "Interact", buttonAction: {
            self.slimeToControl?.interact()
            })
        button.setScale(0.1)
        button.isEnabled = true
        button.position = StageConstants.interactButtonPosition
        button.zPosition = StageConstants.buttonZPos
        return button
    }()

    func setupControl() {
        self.addChild(jumpButton)
        self.addChild(interactButton )
        self.addChild(analogJoystick)

        analogJoystick.trackingHandler = { [unowned self] data in
            if data.velocity.x > 0.0 {
                self.slimeToControl?.moveRight(withSpeed: data.velocity.x)
            } else if data.velocity.x < 0.0 {
                self.slimeToControl?.moveLeft(withSpeed: -data.velocity.x)
            }

            if data.velocity.y > abs(data.velocity.x) {
                self.slimeToControl?.jump()
            }

            if data.velocity.y > 0.0 {
                self.slimeToControl?.moveUp(withSpeed: data.velocity.y)
            } else if data.velocity.y < 0.0 {
                self.slimeToControl?.moveDown(withSpeed: -data.velocity.y)
            }
        }
    }

    func addOrder(ofRecipe recipe: Recipe, withinTime time: Int = StageConstants.defaultTimeLimitOrder) {
        let order = Order(recipe, withinTime: time)
        orders.append(order)
    }

    // if the player is already in the list, will do nothing
    func addPlayer(_ player: Player) {
        if !players.contains(player) && players.count < StageConstants.maxPlayer {
            players.append(player)
        }
    }

    // if the player is not found, will do nothing
    func removePlayer(_ player: Player) {
        players.removeAll { $0 == player }
    }

    override func didSimulatePhysics() {
        self.slimeToControl?.resetMovement()
        super.didSimulatePhysics()
    }

    var slimeToControl: Slime? {
        var playerSlime: Slime?

        spaceship.enumerateChildNodes(withName: "slime") {
            node, stop in

            guard let slime = node as? Slime else {
                return
            }

            playerSlime = slime
            stop.initialize(to: true)
        }
        return playerSlime
    }

    func serve(_ plate: Plate) {
        let foodToServe = plate.food
        let ingredientsPrepared = foodToServe.ingredientsList
        guard let matchedOrder = orders.firstIndex(
                                        where:{ $0.recipeWanted.ingredientsNeeded == ingredientsPrepared }) else {
            return
        }
        orders.remove(at: matchedOrder)
        self.addRandomOrder()
    }

    func generateRandomRecipe() -> Recipe? {
        return self.possibleRecipes.randomElement()?.regenerateRecipe()
    }

    func addRandomOrder() {
        guard let randomRecipe = self.generateRandomRecipe() else {
            return
        }
        self.addOrder(ofRecipe: randomRecipe)
    }

    func generateMenu() {
        let spaceshipBody = SKTexture(imageNamed: "Menu-Slimes_01")
        for (key,value) in (generateRandomRecipe()?.ingredientsNeeded)! {
            print(key.type)
        }
        spaceshipBody.filteringMode = .nearest
        let temp = MenuPrefab.init(texture: spaceshipBody, color: .clear, size: CGSize(width: 100, height: 100))
        temp.addRecipe(inString: "ApplePie")
        self.addChild(temp)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("initiation using storyboard is not implemented yet.")
    }
}
