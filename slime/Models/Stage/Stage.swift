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
    
    // multiplayer stuff
    var isMultiplayer: Bool = false
    var previousRoom: RoomModel?
    var db: GameDatabase?
    var hasStarted: Bool = false
    var gameHasEnded: Bool = false
    var streamingTimer: Timer?
    var isUserHost: Bool = false
    var allSlimesDict: [String : Slime] = [:] // [uid: Slime]
    var allStationsDict: [String : Station] = [:]
    var allStageItemsDict: [String : MobileItem] = [:]
    
    // notification stuff
    var notificationPrefab: NotificationPrefab = NotificationPrefab(color: .clear, size: StageConstants.notificationSize)

    //For countdown of game
    var counter = 0
    var counterTime = Timer()
    var counterStartTime = StageConstants.stageTime
    var isGameOver = false

    // RI: the players are unique
    var players: [Player] = []

    // Order queue
    var orderQueue = OrderQueue(interval: StageConstants.orderComingInterval[0])

    //Level score
    var levelScore: Int = 0

    //Camera
    var sceneCam: SKCameraNode?

    var controller = GameViewController(with: UIView())

    let UIAtlas = SKTextureAtlas(named: "UI")

    override init(size: CGSize = CGSize(width: StageConstants.maxXAxisUnits, height: StageConstants.maxYAxisUnits)) {
        spaceship = Spaceship(inPosition: StageConstants.spaceshipPosition, withSize: StageConstants.spaceshipSize)
        super.init(size: size)

        sceneCam = SKCameraNode()
        self.camera = sceneCam
        self.addChild(sceneCam!)

        let background = SKSpriteNode(imageNamed: "background-1")
        background.position = StageConstants.spaceshipPosition
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        background.size = size
        background.scaleTo(screenWidthPercentage: 2.0)
        background.zPosition = StageConstants.backgroundZPos
        self.addChild(background)
        self.addChild(spaceship)
        
        self.sceneCam?.addChild(notificationPrefab)
        self.sceneCam?.addChild(orderQueue)
    }

    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        if let camera = sceneCam {
            camera.position = (self.slimeToControl?.position)!
        }
    }
    
    func setupSinglePlayer(player: Player) {
        guard let onlyUser = GameAuth.currentUser else {
            return
        }
        
        player.name = onlyUser.uid
        self.addPlayer(player)
    }

    func generateLevel(inLevel levelName: String) {
        if let levelDesignURL = Bundle.main.url(forResource: levelName, withExtension: "plist") {
            do {
                let data = try? Data(contentsOf: levelDesignURL)
                let decoder = PropertyListDecoder()
                let value = try decoder.decode(SerializableGameData.self, from: data!)
                spaceship.setLevelName(inString: levelName)
                spaceship.addRoom()
                
                self.addSlimes(inPosition: value.slimeInitPos)

                spaceship.addWall(inCoord: value.border)
                spaceship.addWall(inCoord: value.blockedArea)
                spaceship.addLadder(inPositions: value.ladder)
                spaceship.addChoppingEquipment(inPositions: value.choppingEquipment, record: &allStationsDict)
                spaceship.addFryingEquipment(inPositions: value.fryingEquipment, record: &allStationsDict)
                spaceship.addOven(inPositions: value.oven, record: &allStationsDict)
                spaceship.addPlateStorage(inPositions: value.plateStorage)
                spaceship.addStoreFront(inPosition: value.storefront)
                spaceship.addTable(inPositions: value.table, record: &allStationsDict)
                spaceship.addTrashBin(inPositions: value.trashBin)

                // add Ingredient Storages (station to take out ingredient) in the spaceship
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

                // initialize the starting orders and the orders pool
                self.initializeOrders(withData: value.possibleRecipes)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func addSlimes(inPosition position: String) {
        if !isMultiplayer { spaceship.addSlime(inPosition: position) }
        self.multiplayerAddSlimes(inPosition: position)
    }

    func setupControl() {
        self.sceneCam?.addChild(jumpButton)
        self.sceneCam?.addChild(interactButton)
        self.sceneCam?.addChild(backButton)
        self.sceneCam?.addChild(analogJoystick)
        self.sceneCam?.addChild(countdownLabel)
        self.sceneCam?.addChild(scoreLabel)

        if !isMultiplayer {
            counter = counterStartTime
            self.showReadyFlag()
        }

        analogJoystick.trackingHandler = { [unowned self] data in
            if self.isMultiplayer && !self.hasStarted { return }
            
            if data.velocity.x > 0.0 {
                self.slimeToControl?.moveRight(withSpeed: data.velocity.x)
            } else if data.velocity.x < 0.0 {
                self.slimeToControl?.moveLeft(withSpeed: -data.velocity.x)
            }

            if data.velocity.y > 0.0 {
                self.slimeToControl?.moveUp(withSpeed: data.velocity.y)
            } else if data.velocity.y < 0.0 {
                self.slimeToControl?.moveDown(withSpeed: -data.velocity.y)
            }
        }
    }

    // Starting Orders Initialization

    private func getIngredient(fromDictionaryData data: [String: String]) -> Ingredient? {
        guard let type = data["type"] else {
            return nil
        }

        guard let ingredientType = IngredientType(rawValue: type) else {
            return nil
        }

        let ingredient = Ingredient(type: ingredientType)

        guard let processingValue = data["processing"] else {
            return nil
        }

        // multiple processing separated by comma in the plist
        for processing in processingValue.split(separator: ",") {

            guard let processingType = CookingType(rawValue: String(processing)) else {
                return nil
            }

            ingredient.cook(by: processingType)
        }

        return ingredient
    }

    func initializeOrders(withData data: [RecipeData]) {
        if !self.checkMultiplayerInitializeOrders() { return }
        
        for datum in data {
            var recipeName: String = ""
            var compulsoryIngredients: [Ingredient] = []
            var optionalIngredients: [(item: Ingredient, probability: Double)] = []
            
            for name in datum["recipeName"] ?? [] {
                recipeName = (name.first?.value)!
            }
            
            for ingredientRequirement in datum["compulsoryIngredients"] ?? [] {
                guard let ingredient = getIngredient(fromDictionaryData: ingredientRequirement) else {
                    continue
                }
                compulsoryIngredients.append(ingredient)
            }
            
            for ingredientRequirement in datum["optionalIngredients"] ?? [] {
                guard let ingredient = getIngredient(fromDictionaryData: ingredientRequirement) else {
                    continue
                }
                
                guard let probabilityString = ingredientRequirement["probability"] else {
                    continue
                }
                
                guard let probability = Double(probabilityString) else {
                    continue
                }
                
                optionalIngredients.append((item: ingredient, probability: probability))
            }
            let recipe = Recipe(inRecipeName: recipeName, withCompulsoryIngredients: compulsoryIngredients,
                                withOptionalIngredients: optionalIngredients)
            self.orderQueue.addPossibleRecipe(recipe)
        }
        self.orderQueue.initialize()
    }

    // For multiplayer (future use)
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

    // when all the players is put into the game
    func setupPlayers() {
        var currentPlayerIndex = 0
        spaceship.enumerateChildNodes(withName: "slime") {
            node, stop in

            guard let slime = node as? Slime else { return }

            guard currentPlayerIndex < self.players.count else {
                stop.initialize(to: true)
                return
            }

            let player = self.players[currentPlayerIndex]
            slime.addUser(player)
            self.allSlimesDict.updateValue(slime, forKey: player.name)
            currentPlayerIndex += 1
        }
        
        orderQueue.interval = StageConstants.orderComingInterval[currentPlayerIndex]
    }
    
    func stageDidLoad() {
        delayMultiplayerJoinGame()
    }

    override func didSimulatePhysics() {
        for (uid, slime) in self.allSlimesDict {
            if uid != GameAuth.currentUser?.uid {
                // not user
                slime.resetMovement(clampVelocity: false)
                continue
            }
            slime.resetMovement(clampVelocity: true)
        }
        super.didSimulatePhysics()
    }

    // which slime to control
    var slimeToControl: Slime? {
        guard let user = GameAuth.currentUser else { return nil }
        return self.allSlimesDict[user.uid]
    }

    // Returns true if serving is successful, and false if not
    func serve(_ plate: Plate) -> Bool {
        if !isMultiplayer {
            let foodToServe = plate.food
            
            guard self.orderQueue.completeOrder(withFood: foodToServe) == true else {
                print("failed")
                return false
            }
            
            levelScore += self.orderQueue.scoreToIncrease 
            scoreLabel.text = "Score: \(levelScore)"
            return true
        }
        
        return self.multiplayerServe(forPlate: plate)
    }

    @objc func startCounter() {
        hasStarted = true
        if !isMultiplayer {
            counterTime = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(decrementCounter), userInfo: nil, repeats: true)
            return
        }
        
        self.setMultiplayerCounter()
    }

    @objc func decrementCounter() {
        if !isGameOver {
            if counter <= 1 {
                isGameOver = true
                gameOver(ifWon: false)
            }

            counter -= 1
            countdownLabel.text = "Time: \(counter)"
        }
    }

    func gameOver(ifWon: Bool, withMessage: String? = nil) {
        cleanup()
        AudioMaster.instance.playSFX(name: "gameover")
        let gameOverPrefab = GameOverPrefab(color: .clear, size: StageConstants.gameOverPrefabSize)
        if self.isMultiplayer { gameOverPrefab.setToMultiplayer() }
        gameOverPrefab.initializeButtons()
        gameOverPrefab.setScore(inScore: levelScore)
        gameOverPrefab.controller = self.controller
        if let message = withMessage { gameOverPrefab.titleLabel.text = message }
        self.sceneCam?.addChild(gameOverPrefab)
    }
    
    func showReadyFlag() {
        self.sceneCam?.addChild(blackBG)
        self.sceneCam?.addChild(readyNode)

        if isMultiplayer { return }
        
        _ = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(showStartFlag), userInfo: nil, repeats: false)
    }
    
    @objc func showStartFlag() {
        self.blackBG.removeFromParent()
        readyNode.texture = UIAtlas.textureNamed("Go")

        _ = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { (timer) in
            self.readyNode.removeFromParent()
            if self.isMultiplayer { return }
            self.startCounter()
        })
    }

    func updateOrderQueue(into orderQueue: OrderQueue) {
        self.orderQueue.removeFromParent()

        self.orderQueue = orderQueue
        self.sceneCam?.addChild(orderQueue)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("initiation using storyboard is not implemented yet.")
    }

    // Setupping Joystick and Buttons
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
        let texture = UIAtlas.textureNamed("JumpButton")
        var button = BDButton(inTexture: texture, buttonAction: {
            self.slimeToControl?.jump()
        })
        button.setScale(0.15)
        button.isEnabled = true
        button.position = StageConstants.jumpButtonPosition
        button.zPosition = StageConstants.buttonZPos
        return button
    }()

    lazy var interactButton: BDButton = {
        let texture = UIAtlas.textureNamed("InteractButton")
        var button = BDButton(inTexture: texture, buttonAction: {
            self.slimeToControl?.interact(onInteractWithStation: { (station, itemCarried) in
                self.handleMultiplayerInteractWithStation(station, itemCarried)
            }, onPickUpItem: { (itemOnGround, itemPickedUp, itemCarried) in
                self.handleMultiplayerPickUpItem(itemOnGround, itemPickedUp, itemCarried)
            }, onDropItem: { (item) in
                self.handleMultiplayerDropItem(item)
            }, onInteractWithItem: { (itemOnGround, itemCarried) in
                self.handleMultiplayerInteractWithItem(itemOnGround, itemCarried)
            })
        })
        button.setScale(0.15)
        button.isEnabled = true
        button.position = StageConstants.interactButtonPosition
        button.zPosition = StageConstants.buttonZPos
        return button
    }()
    
    lazy var backButton: BDButton = {
        let texture = UIAtlas.textureNamed("BackButton")
        var button = BDButton(inTexture: texture, buttonAction: {
            self.handleMultiplayerBackButton()
            self.controller.segueToMainScreen(isMultiplayer: self.isMultiplayer)
        })
        button.setScale(0.1)
        button.isEnabled = true
        button.position = StageConstants.backButtonPosition
        button.zPosition = StageConstants.buttonZPos
        return button
    }()

    lazy var countdownLabel: SKLabelNode = {
        var label = SKLabelNode(fontNamed: "SquidgySlimes")
        label.fontSize = CGFloat(40)
        label.zPosition = StageConstants.countdownLabelZPos
        label.color = .red
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode = .center
        label.text = "Time: \(counterStartTime)"
        label.position = StageConstants.timerPosition
        return label
    }()

    lazy var scoreLabel: SKLabelNode = {
        var label = SKLabelNode(fontNamed: "SquidgySlimes")
        label.fontSize = CGFloat(30)
        label.zPosition = StageConstants.scoreLabelZPos
        label.color = .red
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode = .center
        label.text = "Score: \(levelScore)"
        label.position = StageConstants.scorePosition
        return label
    }()

    lazy var readyNode: SKSpriteNode = {
        let texture = UIAtlas.textureNamed("Ready")
        var label = SKSpriteNode(texture: texture)
        label.size = CGSize(width: ScreenSize.width * 0.5, height: ScreenSize.height * 0.5)
        label.zPosition = StageConstants.readyNodeZPos
        label.position = (self.sceneCam?.position)!
        return label
    }()

    //can reuse this for other purposes
    lazy var blackBG: SKSpriteNode = {
        let blackBG = SKSpriteNode.init(color: .black, size: CGSize(width: ScreenSize.width, height: ScreenSize.height))
        blackBG.alpha = 0.5
        blackBG.zPosition = StageConstants.blackBGOpeningZPos
        return blackBG
    }()
    
    // Deallocate stuff, invalidate timers
    private func cleanup() {
        orderQueue.newOrderTimer.invalidate()
        orderQueue.orderQueueInvalidated = true
    }
    
    func checkFoodName(ofFood food: Food) -> String? {
        for recipe in orderQueue.possibleRecipes {
            if recipe.possibleConsists(of: food) {
                return recipe.recipeName
            }
        }
        return nil
    }

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchPos = touch.location(in: (self.sceneCam)!)
            if (hasStarted && touchPos.x < (self.sceneCam?.position.x)!) {
                analogJoystick.position = touchPos
                analogJoystick.touchesBegan(touches, with: event)
            }
        }
    }

    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        analogJoystick.touchesMoved(touches, with: event)
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        analogJoystick.touchesEnded(touches, with: event)
    }

    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        analogJoystick.touchesCancelled(touches, with: event)
    }
}
