//
//  Stage+Multiplayer.swift
//  slime
//
//  Created by Johandy Tantra on 19/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import SpriteKit

extension Stage {
    func multiplayerAddSlimes(inPosition position: String) {
        if !isMultiplayer { return }
        guard let room = self.previousRoom else { return }
        for _ in room.players { spaceship.addSlime(inPosition: position) }
        self.showReadyFlag()
    }
    
    func checkMultiplayerInitializeOrders() -> Bool {
        if isMultiplayer && !isUserHost {
            return false
        }
        
        if isMultiplayer {
            if let id = self.previousRoom?.id { self.orderQueue.setMultiplayer(withGameId: id) }
        }
        
        return true
    }
    
    func delayMultiplayerJoinGame() {
        if !self.isMultiplayer { return }
        
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { (timer) in
            guard let room = self.previousRoom else { return }
            self.joinGame(forRoom: room)
        }
    }
    
    func setupMultiplayer(forRoom room: RoomModel) {
        self.previousRoom = room
        
        // don't initialize this on single player
        db = GameDB()
        
        guard let user = GameAuth.currentUser else { return }
        guard let database = self.db else { return }
        
        // add all players
        for player in room.players {
            // sets isUserHost in current game instance
            if user.uid == player.uid { self.isUserHost = player.isHost }
            let playerInGame = Player(from: player)
            playerInGame.name = player.uid
            self.addPlayer(playerInGame)
        }
        
        database.observeGameState(forRoom: room, onPlayerUpdate: { (player) in
            guard let currentSlime = self.allSlimesDict[player.uid] else { return }
            
            let move = SKAction.move(to: CGPoint(x: player.positionX, y: player.positionY), duration: 0.1)
            currentSlime.run(move)
            //            currentSlime.position = CGPoint(x: player.positionX, y: player.positionY)
            currentSlime.physicsBody?.velocity = CGVector(dx: player.velocityX, dy: player.velocityY)
            currentSlime.xScale = player.xScale
            self.handleSlimeItemChange(forSlime: currentSlime, forItem: player.holdingItem)
        }, onStationUpdate: { (id, station) in
            self.handleStationChanged(forStationId: id, forStation: station)
        }, onGameEnd: {
            self.gameHasEnded = true
            self.stopStreamingSelf()
            self.gameOver(ifWon: false)
            guard let database = self.db else { return }
            database.removeAllObservers()
            database.removeAllDisconnectObservers()
            if self.isUserHost {
                self.orderQueue.newOrderTimer.invalidate()
                self.orderQueue.orderQueueInvalidated = true
                guard let room = self.previousRoom else { return }
                database.closeGame(forGameId: room.id, { }, { (err) in
                    print(err.localizedDescription)
                })
            }
        }, onOrderQueueChange: { (orderQueue) in
            self.updateOrderQueue(into: orderQueue)
        }, onScoreChange: { (score) in
            self.levelScore = score
            self.scoreLabel.text = "Score: \(self.levelScore)"
        }, onAllPlayersReady: {
            // only for host, stay away
            self.multiplayerIndicateGameHasStarted()
        }, onGameStart: {
            self.hasStarted = true
            self.showStartFlag()
            self.startStreamingSelf()
            if self.isUserHost { self.startCounter() }
            // TODO: do setup when game has started, add stuff whenever necessary
        }, onSelfItemChange: { (item) in
            guard let slime = self.slimeToControl else { return }
            self.handleSlimeItemChange(forSlime: slime, forItem: item)
        }, onTimeLeftChange: { (timeLeft) in
            self.countdownLabel.text = "Time: \(timeLeft)"
            self.checkForNotificationTimes(forTime: timeLeft)
            if self.isUserHost && self.isMultiplayerTimeUp(forTime: timeLeft) { self.endMultiplayerGame() }
        }, onHostDisconnected: {
            self.gameHasEnded = true
            self.stopStreamingSelf()
            self.gameOver(ifWon: false, withMessage: (self.gameHasEnded ? "GAME OVER" : "HOST EXPLODED"))
            guard let database = self.db else { return }
            database.removeAllObservers()
            database.removeAllDisconnectObservers()
        }, onNewOrderSubmitted: { (plate) in
            // only for host
            self.multiplayerHandleServe(forPlate: plate)
        }, onNewNotificationAdded: { (notification) in
            // when new notification is received
            guard let type = NotificationPrefab.NotificationTypes(rawValue: notification.type) else { return }
            self.notificationPrefab.show(withDescription: notification.description, ofType: type)
        }, onStageItemAdded: { (item) in
            // stage item added
            self.handleStageItemAdded(forItem: item)
        }, onStageItemRemoved: { (item) in
            // stage item removed
            self.handleStageItemRemoved(forItem: item)
        }, onStageItemChanged: { (item) in
            self.handleStageItemChanged(forItem: item)
        }, onComplete: {
            // this is run BEFORE the stage fully loads, and only after
            // all listeners are attached refrain from running anything
            // related to game flow here, might be called prematurely
        }) { (err) in
            print(err.localizedDescription)
        }
    }
    
    func joinGame(forRoom room: RoomModel) {
        guard let database = self.db else { return }
        database.joinGame(forRoom: room, { }, { (err) in
            print(err.localizedDescription)
        })
    }
    
    func setMultiplayerCounter() {
        counterTime = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
            guard let database = self.db else { return }
            guard let room = self.previousRoom else { return }
            
            database.decrementTimeLeft(forGameId: room.id, { }, { (err) in
                print(err.localizedDescription)
            })
        })
    }
    
    func multiplayerServe(forPlate plate: Plate) -> Bool {
        // multiplayer serve food
        guard let database = self.db else { return false }
        guard let room = self.previousRoom else { return false }
        
        database.updatePlayerHoldingItem(forGameId: room.id, toItem: "BUH BUH SLIME" as AnyObject, { }) { (err) in
            print(err.localizedDescription)
        }
        
        database.submitOrder(forGameId: room.id, withPlate: plate, { }) { (err) in
            print(err.localizedDescription)
        }
        
        return true
    }
    
    private func startStreamingSelf() {
        self.streamingTimer = Timer.scheduledTimer(withTimeInterval: StageConstants.streamingInterval, repeats: true, block: { (timer) in
            guard let slime = self.slimeToControl else { return }
            guard let room = self.previousRoom else { return }
            guard let slimeVelocity = slime.physicsBody?.velocity else { return }
            guard let database = self.db else { return }
            let slimePos = slime.position
            let slimeXScale = slime.xScale
            
            database.updatePlayerPosition(forGameId: room.id, position: slimePos, velocity: slimeVelocity, xScale: slimeXScale, { }, { (err) in
                print(err.localizedDescription)
            })
        })
    }
    
    private func stopStreamingSelf() {
        guard let timer = self.streamingTimer else { return }
        timer.invalidate()
    }
    
    private func handleStageItemRemoved(forItem item: StageItemModel) {
        let removedItem = self.allStageItemsDict.removeValue(forKey: item.uid)
        guard let item = removedItem else { return }
        if let plate = item as? Plate { plate.removeFromParent() }
        if let ingredient = item as? Ingredient { ingredient.removeFromParent() }
    }
    
    private func handleStageItemAdded(forItem item: StageItemModel) {
        let decoder = JSONDecoder()
        guard let data = item.encodedData.data(using: .utf8) else { return }
        
        if item.type == FirebaseSystemValues.ItemTypes.plate.rawValue {
            let plate = try? decoder.decode(Plate.self, from: data)
            guard let addedPlate = plate else { return }
            self.allStageItemsDict.updateValue(addedPlate as MobileItem, forKey: item.uid)
            self.addChild(addedPlate)
        }
        
        if item.type == FirebaseSystemValues.ItemTypes.ingredient.rawValue {
            let ingredient = try? decoder.decode(Ingredient.self, from: data)
            guard let addedIngredient = ingredient else { return }
            self.allStageItemsDict.updateValue(addedIngredient as MobileItem, forKey: item.uid)
            self.addChild(addedIngredient)
        }
    }
    
    private func handleStageItemChanged(forItem item: StageItemModel) {
        let decoder = JSONDecoder()
        guard let data = item.encodedData.data(using: .utf8) else { return }
        
        if item.type == FirebaseSystemValues.ItemTypes.plate.rawValue {
            let plate = try? decoder.decode(Plate.self, from: data)
            guard let addedPlate = plate else { return }
            print(addedPlate)
            if let currentPlate = allStageItemsDict[item.uid] as? Plate {
                currentPlate.removeFromParent()
            }
            self.allStageItemsDict.updateValue(addedPlate as MobileItem, forKey: item.uid)
            self.addChild(addedPlate)
        }
        
        // I think this wont even be executed but I just put in
        // here just in case lol
        if item.type == FirebaseSystemValues.ItemTypes.ingredient.rawValue {
            let ingredient = try? decoder.decode(Ingredient.self, from: data)
            guard let addedIngredient = ingredient else { return }
            if let currentIngredient = allStageItemsDict[item.uid] as? Ingredient {
                currentIngredient.removeFromParent()
            }
            self.allStageItemsDict.updateValue(addedIngredient as MobileItem, forKey: item.uid)
            self.addChild(addedIngredient)
        }
    }
    
    private func handleSlimeItemChange(forSlime slime: Slime, forItem item: ItemModel) {
        if item.type == FirebaseSystemValues.ItemTypes.none.rawValue {
            slime.removeItem()
        } else if item.type == FirebaseSystemValues.ItemTypes.plate.rawValue {
            guard let plate = self.decodePlateFromString(item.encodedData) else { return }
            slime.removeItem()
            slime.takeItem(plate)
        } else if item.type == FirebaseSystemValues.ItemTypes.ingredient.rawValue {
            guard let ingredient = self.decodeIngredientFromString(item.encodedData) else { return }
            slime.removeItem()
            slime.takeItem(ingredient)
        }
    }
    
    func handleStationChanged(forStationId id: String, forStation station: GameStationModel) {
        guard let stationChanged = self.allStationsDict[id] else { return }
        
        let itemType = station.item.type
        
        if itemType == FirebaseSystemValues.ItemTypes.none.rawValue {
            stationChanged.removeItem()
        } else if itemType == FirebaseSystemValues.ItemTypes.plate.rawValue {
            guard let plate = self.decodePlateFromString(station.item.encodedData) else { return }
            stationChanged.removeItem()
            stationChanged.addItem(plate)
        } else if itemType == FirebaseSystemValues.ItemTypes.ingredient.rawValue {
            guard let ingredient = self.decodeIngredientFromString(station.item.encodedData) else { return }
            stationChanged.removeItem()
            stationChanged.addItem(ingredient)
        }
    }
    
    private func decodeIngredientFromString(_ string: String) -> Ingredient? {
        let decoder = JSONDecoder()
        guard let data = string.data(using: .utf8) else { return nil }
        
        let ingredient = try? decoder.decode(Ingredient.self, from: data)
        guard let item = ingredient else { return nil }
        
        return item
    }
    
    private func decodePlateFromString(_ string: String) -> Plate? {
        let decoder = JSONDecoder()
        guard let data = string.data(using: .utf8) else { return nil }
        
        let plate = try? decoder.decode(Plate.self, from: data)
        guard let item = plate else { return nil }
        
        return item
    }
    
    func multiplayerIndicateGameHasStarted() {
        guard let database = self.db else { return }
        guard let room = self.previousRoom else { return }
        
        database.updateGameHasStarted(forGameId: room.id, to: true, { }, { (err) in
            print(err.localizedDescription)
        })
    }
    
    func multiplayerHandleServe(forPlate plate: Plate) {
        if !self.isMultiplayer { return }
        
        let food = plate.food
        guard let database = self.db else { return }
        guard let room = self.previousRoom else { return }
        
        guard self.orderQueue.completeOrder(withFood: food) == true else {
            database.sendNotification(forGameId: room.id, withDescription: "wrong order, bud!", withType: NotificationPrefab.NotificationTypes.warning.rawValue, { }) { (err) in
                print(err.localizedDescription)
            }
            return
        }

        database.addScore(by: 20, forGameId: room.id, {
            database.sendNotification(forGameId: room.id, withDescription: "order completed! great job!", withType: NotificationPrefab.NotificationTypes.info.rawValue, { }, { (err) in
                print(err.localizedDescription)
            })
        }) { (err) in
            print(err.localizedDescription)
        }
    }

    func handleMultiplayerPickUpItem(_ itemOnGround: MobileItem, _ itemPickedUp: MobileItem, _ itemCarried: MobileItem?) {
        if !isMultiplayer { return }
        guard let database = self.db else { return }
        guard let room = self.previousRoom else { return }
        guard let id = itemOnGround.id else { return }
        
        database.removeStageItem(forGameId: room.id, withItemUid: id, onItemAlreadyRemoved: {
            if let _ = self.slimeToControl?.itemCarried as? Ingredient {
                database.updatePlayerHoldingItem(forGameId: room.id, toItem: "BLAH BLAH" as AnyObject, { }, { (err) in
                    print(err.localizedDescription)
                })
                return
            }
            
            if let _ = self.slimeToControl?.itemCarried as? Plate {
                self.slimeToControl?.undoInteract()
                if let res = self.slimeToControl?.itemCarried {
                    database.updatePlayerHoldingItem(forGameId: room.id, toItem: res, { }, { (err) in
                        print(err.localizedDescription)
                    })
                } else {
                    database.updatePlayerHoldingItem(forGameId: room.id, toItem: "BLAH BLAH" as AnyObject, { }, { (err) in
                        print(err.localizedDescription)
                    })
                }
            }
        }, onItemPickedUp: { (item) in
            database.updatePlayerHoldingItem(forGameId: room.id, toItem: itemPickedUp, { }) { (err) in
                print(err.localizedDescription)
            }
        }, { }) { (err) in
            print(err.localizedDescription)
        }
    }
    
    func handleMultiplayerInteractWithItem(_ itemOnGround: MobileItem, _ itemCarried: MobileItem?) {
        if !isMultiplayer { return }
        guard let database = self.db else { return }
        guard let room = self.previousRoom else { return }
        guard let id = itemOnGround.id else { return }
        guard let item = itemCarried else { return }
        
        database.updateStageItem(forGameId: room.id, withItemOnGround: itemOnGround, withItemCarried: item, withItemUid: id, onItemChange: { (plate, item) in
            guard let itemInteracted = item else { return }
            plate.removeFromParent()
            self.addChild(plate)
            let _ = plate.interact(withItem: itemInteracted)
            plate.removeFromParent()
        }, { }) { (err) in
            print(err.localizedDescription)
        }
        
        database.updatePlayerHoldingItem(forGameId: room.id, toItem: "BUH BYE" as AnyObject, { }) { (err) in
            print(err.localizedDescription)
        }
    }
    
    func handleMultiplayerDropItem(_ item: MobileItem) {
        if !isMultiplayer { return }
        guard let database = self.db else { return }
        guard let room = self.previousRoom else { return }
        guard let id = item.id else { return }
        
        // remove from parent to prevent duplication
        item.removeFromParent()
        
        database.updatePlayerHoldingItem(forGameId: room.id, toItem: "BUH BUH Sling" as AnyObject, { }) { (err) in
            print(err.localizedDescription)
        }
        
        database.addStageItem(forGameId: room.id, withItem: item, withItemUid: id, { }) { (err) in
            print(err.localizedDescription)
        }
    }
    
    func handleMultiplayerInteractWithStation(_ station: Station, _ itemCarried: MobileItem?) {
        if !isMultiplayer { return }
        guard let database = self.db else { return }
        guard let room = self.previousRoom else { return }
        guard let id = station.id else { return }
        
        if let _ = station as? Table {
            database.handleInteractWithTable(forGameId: room.id, forStation: id, itemCarried: itemCarried, onItemAlreadyRemoved: {
                // placeholder for STePS
                if let ingredient = self.slimeToControl?.itemCarried as? Ingredient {
                    database.updatePlayerHoldingItem(forGameId: room.id, toItem: "MUH MUH BRO" as AnyObject, { }, { (err) in
                        print(err.localizedDescription)
                    })
                    database.updateStationItemInside(forGameId: room.id, forStation: id, toItem: ingredient, { }, { (err) in
                        print(err.localizedDescription)
                    })
                }
                // placeholder for STePS
                if let _ = self.slimeToControl?.itemCarried as? Plate {
                    self.slimeToControl?.undoInteract()
                    if let newPlate = self.slimeToControl?.itemCarried {
                        database.updatePlayerHoldingItem(forGameId: room.id, toItem: newPlate, { }, { (err) in
                            print(err.localizedDescription)
                        })
                    }
                }
            }, onItemInteract: { (plate, item) in
                plate.removeFromParent()
                self.addChild(plate)
                let _ = plate.interact(withItem: item)
                plate.removeFromParent()
            }, {
                // completion block
            }) { (err) in
                print(err.localizedDescription)
            }
            return
        }
        
        if let item = station.itemInside {
            database.updateStationItemInside(forGameId: room.id, forStation: id, toItem: item, { }) { (err) in
                print(err.localizedDescription)
            }
        } else {
            database.updateStationItemInside(forGameId: room.id, forStation: id, toItem: "MAH MAH SLIME" as AnyObject, { }) { (err) in
                print(err.localizedDescription)
            }
        }
        
        if let selfItem = self.slimeToControl?.itemCarried {
            database.updatePlayerHoldingItem(forGameId: room.id, toItem: selfItem, { }) { (err) in
                print(err.localizedDescription)
            }
        } else {
            database.updatePlayerHoldingItem(forGameId: room.id, toItem: "AH AH SLIME" as AnyObject, { }) { (err) in
                print(err.localizedDescription)
            }
        }
    }
    
    func handleMultiplayerBackButton() {
        if !isMultiplayer { return }
        guard let database = self.db else { return }
        guard let room = self.previousRoom else { return }
        self.stopStreamingSelf()
        database.removeAllObservers()
        database.removeAllDisconnectObservers()
        if self.isUserHost {
            self.orderQueue.newOrderTimer.invalidate()
            self.orderQueue.orderQueueInvalidated = true
            database.closeGame(forGameId: room.id, { }, { (err) in
                print(err.localizedDescription)
            })
        }
    }
    
    private func endMultiplayerGame() {
        counterTime.invalidate()
        guard let database = self.db else { return }
        guard let room = self.previousRoom else { return }
        
        database.updateGameHasEnded(forGameId: room.id, to: true, { }) { (err) in
            print(err.localizedDescription)
        }
    }
    
    private func isMultiplayerTimeUp(forTime time: Int) -> Bool {
        if time <= 0 { return true }
        return false
    }
    
    private func checkForNotificationTimes(forTime time: Int) {
        guard let database = self.db else { return }
        guard let gameId = self.previousRoom?.id else { return }
        
        if time == 60 {
            database.sendNotification(forGameId: gameId, withDescription: "less than 60 seconds left!", withType: NotificationPrefab.NotificationTypes.warning.rawValue, { }) { (err) in
                print(err.localizedDescription)
            }
        }
        
        if time == 10 {
            database.sendNotification(forGameId: gameId, withDescription: "less than 10 seconds left!!", withType: NotificationPrefab.NotificationTypes.warning.rawValue, { }) { (err) in
                print(err.localizedDescription)
            }
        }
    }
}
