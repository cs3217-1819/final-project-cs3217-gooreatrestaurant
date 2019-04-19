//
//  GameDB.swift
//  slime
//
//  Created by Johandy Tantra on 4/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import Firebase

/**
 Implementation of GameDatabase using
 Firebase Realtime Database
 */
class GameDB: GameDatabase {
    var dbRef: DatabaseReference = Database.database().reference()
    internal var observers: [Observer] = []
    internal var disconnectObservers: [DatabaseReference] = []

    required init() {
        // add initializers
    }

    // MARK: Methods related to Room state

    func observeRoomState(forRoomId id: String, _ onDataChange: @escaping (RoomModel) -> Void, _ onRoomClose: @escaping () -> Void, _ onError: @escaping (Error) -> Void) {
        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.rooms, id]))

        let handle = ref.observe(.value, with: { (snap) in
            guard let roomDict = snap.value as? [String: AnyObject] else {
                // room closed or removed
                onRoomClose()
                return
            }

            onDataChange(self.firebaseRoomModelFactory(forDict: roomDict))
        }) { (err) in
            onError(err)
        }

        self.observers.append(Observer(withHandle: handle, withRef: ref))
    }
    
    func joinRoom(forRoomId id: String, withUser userChar: UserCharacter, _ onSuccess: @escaping () -> Void, _ onRoomFull: @escaping () -> Void, _ onRoomNotExist: @escaping () -> Void, _ onGameHasStarted: @escaping () -> Void, _ onError: @escaping (Error) -> Void) {
        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.rooms, id]))

        guard let user = GameAuth.currentUser else {
            return
        }

        ref.observeSingleEvent(of: .value, with: { (snap) in

            guard let roomDict = snap.value as? [String: AnyObject] else {
                // room not valid
                onRoomNotExist()
                return
            }

            guard let hasStarted = roomDict[FirebaseKeys.rooms_hasStarted] as? Bool else {
                return
            }

            if hasStarted {
                // invalid room
                onGameHasStarted()
                return
            }

            guard let players = roomDict[FirebaseKeys.rooms_players] as? [String: AnyObject] else {
                return
            }

            if players[user.uid] != nil {
                // player already inside game
                return
            }

            if players.count >= 4 {
                // room full
                onRoomFull()
                return
            }

            let playerDict = self.createRoomPlayerDict(isHost: false, uid: user.uid, forUser: userChar)
            
            let currentUserRef = ref.child(FirebaseKeys.joinKeys([FirebaseKeys.rooms_players, user.uid]))
            
            currentUserRef.setValue(playerDict, withCompletionBlock: { (err, _) in
                if let error = err {
                    onError(error)
                    return
                }
                
                // set disconnect flag, remove player from room
                currentUserRef.onDisconnectRemoveValue()
                self.disconnectObservers.append(currentUserRef)
                
                onSuccess()
            })
        }) { (err) in
            onError(err)
        }
    }

    func changeRoomOpenState(forRoomId id: String, _ onError: @escaping (Error) -> Void) {
        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.rooms, id, FirebaseKeys.rooms_players_isHost]))

        ref.observeSingleEvent(of: .value) { (snap) in
            guard let isOpen = snap.value as? Bool else {
                return
            }

            ref.setValue(!isOpen, withCompletionBlock: { (err, _) in
                if let error = err {
                    onError(error)
                    return
                }
            })
        }
    }

    func changeReadyState(forRoomId id: String, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void) {
        guard let user = GameAuth.currentUser else {
            return
        }

        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.rooms, id, FirebaseKeys.rooms_players, user.uid, FirebaseKeys.rooms_players_isReady]))

        ref.observeSingleEvent(of: .value, with: { (snap) in
            guard let isReady = snap.value as? Bool else {
                return
            }

            ref.setValue(!isReady, withCompletionBlock: { (err, _) in
                if let error = err {
                    onError(error)
                    return
                }
            })
        }) { (err) in
            onError(err)
        }
    }

    func updateRoomName(to roomName: String, forRoomId id: String, _ onError: @escaping (Error) -> Void) {
        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.rooms, id, FirebaseKeys.rooms_roomName]))

        ref.setValue(roomName) { (err, _) in
            if let error = err {
                // escapes function if error
                onError(error)
                return
            }
        }
    }

    func createRoom(withRoomName name: String, withMap map: String, withUser userChar: UserCharacter, _ onSuccess: @escaping (String) -> Void, _ onError: @escaping (Error) -> Void) {
        let roomId = generateRandomId()
        
        guard let user = GameAuth.currentUser else {
            return
        }
        
        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.rooms, roomId]))

        ref.observeSingleEvent(of: .value, with: { (snap) in
            if snap.value as? [String: AnyObject] != nil {
                // room exists
                self.createRoom(withRoomName: name, withMap: map, withUser: userChar, { id in
                    onSuccess(id)
                }, { (err) in
                    onError(err)
                })
            }
            
            let playerDict = self.createRoomPlayerDict(isHost: true, uid: user.uid, forUser: userChar)
            
            var roomDict: [String: AnyObject] = [:]
            
            // populates dictionary to fit the db
            roomDict.updateValue(name as AnyObject, forKey: FirebaseKeys.rooms_roomName)
            roomDict.updateValue(map as AnyObject, forKey: FirebaseKeys.rooms_mapName)
            roomDict.updateValue(roomId as AnyObject, forKey: FirebaseKeys.rooms_roomId)
            roomDict.updateValue(FirebaseSystemValues.defaultFalse as AnyObject, forKey: FirebaseKeys.rooms_hasStarted)
            roomDict.updateValue(FirebaseSystemValues.defaultFalse as AnyObject, forKey: FirebaseKeys.rooms_isGameCreated)
            roomDict.updateValue(FirebaseSystemValues.defaultFalse as AnyObject, forKey: FirebaseKeys.rooms_isOpen)
            roomDict.updateValue([user.uid: playerDict] as AnyObject, forKey: FirebaseKeys.rooms_players)
            
            ref.setValue(roomDict, withCompletionBlock: { (err, ref) in
                if let error = err {
                    onError(error)
                    return
                }
                
                // closes room on disconnect
                ref.onDisconnectRemoveValue()
                self.disconnectObservers.append(ref)
                
                onSuccess(roomId)
            })
        }) { (err) in
            onError(err)
        }
    }

    func closeRoom(forRoomId id: String, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void) {
        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.rooms, id]))

        guard let user = Auth.auth().currentUser else {
            return
        }

        ref.child(FirebaseKeys.joinKeys([FirebaseKeys.rooms_players, user.uid, FirebaseKeys.rooms_players_isHost])).observeSingleEvent(of: .value, with: { (snap) in
            guard snap.value as? Bool ?? false else {
                // user is not host, unable to close room
                return
            }

            ref.setValue(nil, withCompletionBlock: { (err, _) in
                if let error = err {
                    onError(error)
                    return
                }

                print("Room \(id) closed")
            })
        }) { (err) in
            onError(err)
        }
    }

    func leaveRoom(fromRoomId id: String, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void) {
        guard let user = Auth.auth().currentUser else {
            print("Invalid user, unable to create room")
            return
        }

        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.rooms, id, FirebaseKeys.rooms_players, user.uid]))
        let isHostRef = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.rooms, id, FirebaseKeys.rooms_players, user.uid, FirebaseKeys.rooms_players_isHost]))

        isHostRef.observeSingleEvent(of: .value, with: { (snap) in
            guard let isHost = snap.value as? Bool else {
                // player does not exist
                return
            }

            if isHost {
                // close entire room if leaving is host
                self.closeRoom(forRoomId: id, {
                    // onComplete
                }, { (err) in
                    onError(err)
                })
            } else {
                ref.setValue(nil, withCompletionBlock: { (err, _) in
                    if let error = err {
                        onError(error)
                        return
                    }
                })
            }

            onComplete()
        }) { (err) in
            onError(err)
        }
    }

    func getOpenRooms(limitTo count: Int, _ onError: @escaping (Error) -> Void) -> [RoomModel] {
        let ref = dbRef.child(FirebaseKeys.rooms).queryEqual(toValue: true, childKey: FirebaseKeys.rooms_isOpen).queryLimited(toFirst: UInt(count))
        let listOfRooms: [RoomModel] = []

        ref.observeSingleEvent(of: .value, with: { (_) in
            //            guard let roomDict = snap.value as? [String : AnyObject] else {
            //                return
            //            }

            //            for (id, room) in roomDict {
            //                let roomDescriptionDict = room as? [String : AnyObject]
            //                // TODO
            //            }
        }) { (_) in
            // ah
        }

        return listOfRooms
    }

    func startGame(forRoom room: RoomModel, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void) {

        let hasStartedRef = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.rooms, room.id, FirebaseKeys.rooms_hasStarted]))
        let gameCreatedRef = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.rooms, room.id, FirebaseKeys.rooms_isGameCreated]))

        hasStartedRef.setValue(true) { (err, ref) in
            if let error = err {
                // escapes closure ir error
                onError(error)
                return
            }

            self.createGame(forRoom: room, {
                // sets the room created flag to true
                gameCreatedRef.setValue(true, withCompletionBlock: { (err, ref) in
                    if let error = err {
                        onError(error)
                        return
                    }

                    onComplete()
                })
            }, { (err) in
                onError(err)
            })
        }
    }

    func createGame(forRoom room: RoomModel, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void) {
        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, room.id]))

        // populates dictionary required for game
        var gameDict: [String : AnyObject] = [:]
        
        let players = createGamePlayersDict(forMap: room.map, forPlayers: room.players)
        let stationsDict = generateStationsDict(forMap: room.map)

        // populates dictionary to fit the db
        gameDict.updateValue(room.map as AnyObject, forKey: FirebaseKeys.games_gameMap)
        gameDict.updateValue(FirebaseSystemValues.defaultFalse as AnyObject, forKey: FirebaseKeys.games_hasEnded)
        gameDict.updateValue(StageConstants.multiplayerStageTime as AnyObject, forKey: FirebaseKeys.games_timeLeft)
        gameDict.updateValue(NSTimeIntervalSince1970 as AnyObject, forKey: FirebaseKeys.games_startTime)
        gameDict.updateValue(FirebaseSystemValues.defaultNoItem as AnyObject, forKey: FirebaseKeys.games_orderQueue)
        gameDict.updateValue(FirebaseSystemValues.defaultFalse as AnyObject, forKey: FirebaseKeys.games_hasStarted)
        gameDict.updateValue(0 as AnyObject, forKey: FirebaseKeys.games_score)
        gameDict.updateValue(players as AnyObject, forKey: FirebaseKeys.games_players)
        gameDict.updateValue(stationsDict as AnyObject, forKey: FirebaseKeys.games_stations)
        
        ref.setValue(gameDict) { (err, ref) in
            if let error = err {
                onError(error)
                return
            }

            onComplete()
        }
    }
    
    func updateGameHasStarted(forGameId id: String, to hasStarted: Bool, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void) {
        let hasStartedRef = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, id, FirebaseKeys.games_hasStarted]))
        
        hasStartedRef.setValue(hasStarted) { (err, ref) in
            if let error = err {
                onError(error)
                return
            }
            
            onComplete()
        }
    }

    func joinGame(forRoom room: RoomModel, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void) {
        guard let user = GameAuth.currentUser else {
            return
        }

        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, room.id, FirebaseKeys.games_players, user.uid]))

        let disconnectRef = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, room.id, FirebaseKeys.games_players, user.uid, FirebaseKeys.games_players_isConnected]))
        let rejoinRef = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.rejoins, user.uid]))

        let res = [FirebaseKeys.games_players_isConnected: true,
                   FirebaseKeys.games_players_isReady: true]
        
        ref.updateChildValues(res) { (err, ref) in
            if let error = err {
                onError(error)
                return
            }
            
            disconnectRef.onDisconnectSetValue(false)
            rejoinRef.onDisconnectSetValue(room.id)
            self.disconnectObservers.append(disconnectRef)
            self.disconnectObservers.append(rejoinRef)
            
            if self.hostInRoom(room) == user.uid {
                let hostRoomDisconnectRef = self.dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.rooms, room.id]))
                let hostGameDisconnectRef = self.dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, room.id]))
                
                hostRoomDisconnectRef.onDisconnectRemoveValue()
                hostGameDisconnectRef.onDisconnectRemoveValue()
                self.disconnectObservers.append(hostRoomDisconnectRef)
                self.disconnectObservers.append(hostGameDisconnectRef)
            }
            
            onComplete()
        }
    }

    func updatePlayerPosition(forGameId id: String, position: CGPoint, velocity: CGVector, xScale: CGFloat, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void) {
        guard let user = GameAuth.currentUser else {
            return
        }

        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, id, FirebaseKeys.games_players, user.uid]))
        
        let resultDict = [FirebaseKeys.games_players_positionX: position.x,
                          FirebaseKeys.games_players_positionY: position.y,
                          FirebaseKeys.games_players_velocityX: velocity.dx,
                          FirebaseKeys.games_players_velocityY: velocity.dy,
                          FirebaseKeys.games_players_xScale: xScale]
        
        ref.updateChildValues(resultDict) { (err, ref) in
            if let error = err {
                onError(error)
                return
            }
            
            onComplete()
        }
    }
    
    func decrementTimeLeft(forGameId id: String, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void) {
        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, id, FirebaseKeys.games_timeLeft]))
        
        ref.runTransactionBlock({ (current) -> TransactionResult in
            guard var time = current.value as? Int else {
                return TransactionResult.success(withValue: current)
            }
            
            time -= 1
            current.value = time
            
            return TransactionResult.success(withValue: current)
        }, andCompletionBlock: { (err, committed, snap) in
            if let error = err {
                onError(error)
                return
            }
            
            onComplete()
        })
    }

    func submitOrder(forGameId id: String, withPlate plate: Plate, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void) {
        // encode recipe first
        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, id, FirebaseKeys.games_ordersSubmitted]))
        
        guard let key = ref.childByAutoId().key else { return }
        
        guard let newOrder = self.convertPlateToEncodedData(forPlate: plate) else { return }
        
        ref.child(key).setValue(newOrder) { (err, ref) in
            if let error = err {
                onError(error)
                return
            }
            
            onComplete()
        }
    }
    
    func addStageItem(forGameId id: String, withItem item: AnyObject, withItemUid uid: String, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void) {
        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, id, FirebaseKeys.games_stageItems, uid]))
        
        ref.runTransactionBlock({ (current) -> TransactionResult in
            if var _ = current.value as? [String : String] {
                return TransactionResult.success(withValue: current)
            }
            
            guard let encodedDict = self.convertStageItemToEncodedData(withUid: uid, withItem: item) else {
                return TransactionResult.success(withValue: current)
            }
            
            current.value = encodedDict
            
            return TransactionResult.success(withValue: current)
        }, andCompletionBlock: { (err, committed, snap) in
            if let error = err {
                onError(error)
                return
            }
            
            onComplete()
        })
    }
    
    func updateStageItem(forGameId id: String, withItemOnGround itemOnGround: AnyObject, withItemCarried itemCarried: AnyObject, withItemUid uid: String, onItemChange: @escaping (Plate, MobileItem?) -> Void, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void) {
        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, id, FirebaseKeys.games_stageItems, uid]))
        
        ref.runTransactionBlock({ (current) -> TransactionResult in
            guard var currentData = current.value as? [String : String] else {
                return TransactionResult.success(withValue: current)
            }
            
            guard let encodedData = currentData[FirebaseKeys.games_stageItems_encodedData] else {
                return TransactionResult.success(withValue: current)
            }
            
            guard let plate = self.convertEncodedDataToPlate(withEncodedData: encodedData) else { return TransactionResult.success(withValue: current) }
            
//            let _ = plate.interact(withItem: itemCarried as? MobileItem)
            onItemChange(plate, itemCarried as? MobileItem)
            
            guard let item = itemOnGround as? MobileItem else { return TransactionResult.success(withValue: current) }
            
            plate.position = item.position
            
            guard let resultingString = self.encodePlateToString(withPlate: plate) else { return TransactionResult.success(withValue: current) }
            
            currentData.updateValue(resultingString, forKey: FirebaseKeys.games_stageItems_encodedData)
            
            current.value = currentData
            
            return TransactionResult.success(withValue: current)
        }, andCompletionBlock: { (err, committed, snap) in
            if let error = err {
                onError(error)
                return
            }
            
            onComplete()
        })
    }
    
    func removeStageItem(forGameId id: String, withItemUid uid: String, onItemAlreadyRemoved: @escaping () -> Void, onItemPickedUp: @escaping (MobileItem) -> Void, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void) {
        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, id, FirebaseKeys.games_stageItems, uid]))
        
        ref.runTransactionBlock({ (current) -> TransactionResult in
            guard var currentData = current.value as? [String : String] else {
                onItemAlreadyRemoved()
                return TransactionResult.success(withValue: current)
            }
            
            guard let encodedString = currentData[FirebaseKeys.games_stageItems_encodedData] else { return TransactionResult.success(withValue: current) }
            
            let item = self.convertEncodedDataToMobileItem(forString: encodedString)
            
            guard let pickedUpItem = item else { return TransactionResult.success(withValue: current) }
            
            current.value = nil
            onItemPickedUp(pickedUpItem)
            return TransactionResult.success(withValue: current)
        }, andCompletionBlock: { (err, committed, snap) in
            if let error = err {
                onError(error)
                return
            }
            
            onComplete()
        })
    }
    
    func updateOrderQueue(forGameId id: String, withOrderQueue oq: OrderQueue, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void) {
        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, id, FirebaseKeys.games_orderQueue]))
        
        guard let newOrderQueue = self.convertOrderQueueToEncodedData(forOrderQueue: oq) else { return }
        
        ref.runTransactionBlock({ (current) -> TransactionResult in
            guard var orderQueue = current.value as? String else {
                return TransactionResult.success(withValue: current)
            }
            
            orderQueue = newOrderQueue
            current.value = orderQueue
            return TransactionResult.success(withValue: current)
        }) { (err, committed, snap) in
            if let error = err {
                onError(error)
                return
            }
            
            onComplete()
        }
    }

    func changeRoomMap(fromRoomId id: String, toMapId mapId: String, _ onError: @escaping (Error) -> Void) {
        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.rooms, id, FirebaseKeys.rooms_mapName]))

        ref.setValue(mapId) { (err, _) in
            if let error = err {
                onError(error)
                return
            }
        }
    }

    func observeGameState(forRoom room: RoomModel, onPlayerUpdate: @escaping (GamePlayerModel) -> Void, onStationUpdate: @escaping (String, GameStationModel) -> Void, onGameEnd: @escaping () -> Void, onOrderQueueChange: @escaping (OrderQueue) -> Void, onScoreChange: @escaping (Int) -> Void, onAllPlayersReady: @escaping () -> Void, onGameStart: @escaping () -> Void, onSelfItemChange: @escaping (ItemModel) -> Void, onTimeLeftChange: @escaping (Int) -> Void, onHostDisconnected: @escaping () -> Void, onNewOrderSubmitted: @escaping (Plate) -> Void, onNewNotificationAdded: @escaping (NotificationModel) -> Void, onStageItemAdded: @escaping (StageItemModel) -> Void, onStageItemRemoved: @escaping (StageItemModel) -> Void, onStageItemChanged: @escaping (StageItemModel) -> Void, onComplete: @escaping () -> Void, onError: @escaping (Error) -> Void) {
        guard let user = GameAuth.currentUser else {
            return
        }
        
        let playerRef = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, room.id, FirebaseKeys.games_players]))
        let scoreRef = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, room.id, FirebaseKeys.games_score]))
        let endRef = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, room.id, FirebaseKeys.games_hasEnded]))
        let hasStartedRef = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, room.id, FirebaseKeys.games_hasStarted]))
        let timeLeftRef = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, room.id, FirebaseKeys.games_timeLeft]))
        let selfHoldingItemRef = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, room.id, FirebaseKeys.games_players, user.uid, FirebaseKeys.games_players_holdingItem]))
        let stageItemRef = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, room.id, FirebaseKeys.games_stageItems]))
        let notificationRef = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, room.id, FirebaseKeys.games_notifications]))
        
        let selfHandle = selfHoldingItemRef.observe(.value, with: { (snap) in
            guard let itemInsideDict = snap.value as? [String : String] else {
                return
            }
            
            let itemType = itemInsideDict[FirebaseKeys.games_items_type] ?? FirebaseSystemValues.ItemTypes.none.rawValue
            let encodedData = itemInsideDict[FirebaseKeys.games_items_encodedData] ?? FirebaseSystemValues.defaultNoItem
            
            onSelfItemChange(ItemModel(type: itemType, encodedData: encodedData))
        }) { (err) in
            onError(err)
        }
        
        let timeLeftHandle = timeLeftRef.observe(.value, with: { (snap) in
            guard let timeLeft = snap.value as? Int else {
                return
            }
            
            onTimeLeftChange(timeLeft)
        }) { (err) in
            onError(err)
        }
        
        if hostInRoom(room) == user.uid {
            let playerReadyRef = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, room.id, FirebaseKeys.games_players]))
            let newOrderRef = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, room.id, FirebaseKeys.games_ordersSubmitted]))
            
            let playerReadyHandle = playerReadyRef.observe(.value, with: { (snap) in
                guard let playerDict = snap.value as? [String : AnyObject] else {
                    return
                }
                
                var allPlayersReady = true
                
                for player in playerDict {
                    let playerState = player.value as? [String : AnyObject] ?? [:]
                    
                    let isReady = playerState[FirebaseKeys.games_players_isReady] as? Bool ?? FirebaseSystemValues.defaultFalse
                    
                    if !isReady { allPlayersReady = false }
                }
                
                if allPlayersReady {
                    // removes observer related to player ready state
                    // when everyone is ready
                    playerReadyRef.removeAllObservers()
                    onAllPlayersReady()
                }
            }) { (err) in
                onError(err)
            }
            
            let newOrderHandle = newOrderRef.observe(.childAdded, with: { (snap) in
                guard let order = snap.value as? String else { return }
                guard let plate = self.firebasePlateFactory(forEncodedString: order) else { return }
                
                onNewOrderSubmitted(plate)
            }) { (err) in
                onError(err)
            }
            
            self.observers.append(Observer(withHandle: playerReadyHandle, withRef: playerReadyRef))
            self.observers.append(Observer(withHandle: newOrderHandle, withRef: newOrderRef))
        } else {
            let orderQueueRef = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, room.id, FirebaseKeys.games_orderQueue]))
            
            let orderQueueHandle = orderQueueRef.observe(.value, with: { (snap) in
                guard let orderQueue = snap.value as? String else {
                    return
                }
                
                guard let oq = self.firebaseOrderQueueFactory(forEncodedString: orderQueue) else { return }
                
                onOrderQueueChange(oq)
            }) { (err) in
                onError(err)
            }
            
            self.observers.append(Observer(withHandle: orderQueueHandle, withRef: orderQueueRef))
        }
        
        hasStartedRef.observe(.value, with: { (snap) in
            guard let hasStarted = snap.value as? Bool else { return }
            if hasStarted { onGameStart() }
        }) { (err) in
            onError(err)
        }

        for player in room.players {
            if player.uid == user.uid { continue }
            
            let indPlayerRef = playerRef.child(player.uid)
            let playerHandle = indPlayerRef.observe(.value, with: { (snap) in
                guard let playerDict = snap.value as? [String : AnyObject] else { return }
                
                onPlayerUpdate(self.firebaseGamePlayerModelFactory(withPlayerUid: player.uid, forDict: playerDict))
            }, withCancel: { (err) in
                onError(err)
            })

            self.observers.append(Observer(withHandle: playerHandle, withRef: indPlayerRef))
        }

        let scoreHandle = scoreRef.observe(.value, with: { (snap) in
            guard let score = snap.value as? Int else {
                onHostDisconnected()
                return
            }
            onScoreChange(score)
        }) { (err) in
            onError(err)
        }

        let listOfStationIds = self.generateStationIdList(fromMap: room.map)
        
        for stationId in listOfStationIds {
            let stationRef = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, room.id, FirebaseKeys.games_stations, stationId]))
            
            let stationHandle = stationRef.observe(.value, with: { (snap) in
                guard let dict = snap.value as? [String : AnyObject] else { return }
                
                onStationUpdate(stationId, self.firebaseGameStationModelFactory(forDict: dict))
            }) { (err) in
                onError(err)
            }
            
            observers.append(Observer(withHandle: stationHandle, withRef: stationRef))
        }
        
        let notificationHandle = notificationRef.observe(.childAdded, with: { (snap) in
            guard let res = snap.value as? [String : String] else { return }
            
            onNewNotificationAdded(self.firebaseNotificationModelFactory(forData: res))
        }) { (err) in
            onError(err)
        }
        
        let onStageItemAddedHandle = stageItemRef.observe(.childAdded, with: { (snap) in
            guard let res = snap.value as? [String : String] else { return }
            onStageItemAdded(self.firebaseStageItemModelFactory(fromData: res))
        }) { (err) in
            onError(err)
        }
        
        let onStageItemRemovedHandle = stageItemRef.observe(.childRemoved, with: { (snap) in
            guard let res = snap.value as? [String : String] else { return }
            onStageItemRemoved(self.firebaseStageItemModelFactory(fromData: res))
        }) { (err) in
            onError(err)
        }
        
        let onStageItemChangedHandle = stageItemRef.observe(.childChanged, with: { (snap) in
            guard let res = snap.value as? [String : String] else { return }
            onStageItemChanged(self.firebaseStageItemModelFactory(fromData: res))
        }) { (err) in
            onError(err)
        }

        let endHandle = endRef.observe(.value, with: { (snap) in
            guard let end = snap.value as? Bool else { return }
            if end { onGameEnd() }
        }) { (err) in
            onError(err)
        }

        self.observers.append(Observer(withHandle: scoreHandle, withRef: scoreRef))
        self.observers.append(Observer(withHandle: endHandle, withRef: endRef))
        self.observers.append(Observer(withHandle: selfHandle, withRef: selfHoldingItemRef))
        self.observers.append(Observer(withHandle: timeLeftHandle, withRef: timeLeftRef))
        self.observers.append(Observer(withHandle: notificationHandle, withRef: notificationRef))
        self.observers.append(Observer(withHandle: onStageItemAddedHandle, withRef: stageItemRef))
        self.observers.append(Observer(withHandle: onStageItemRemovedHandle, withRef: stageItemRef))
        self.observers.append(Observer(withHandle: onStageItemChangedHandle, withRef: stageItemRef))
        
        onComplete()
    }
    
    func sendNotification(forGameId id: String, withDescription description: String, withType type: String, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void) {
        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, id, FirebaseKeys.games_notifications]))
        
        let res = [FirebaseKeys.games_notifications_description: description,
                   FirebaseKeys.games_notifications_type: type]
        
        guard let key = ref.childByAutoId().key else { return }
        
        ref.child(key).setValue(res) { (err, ref) in
            if let error = err {
                onError(error)
                return
            }
            
            onComplete()
        }
    }
    
    func updateGameHasEnded(forGameId id: String, to hasEnded: Bool, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void) {
        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, id, FirebaseKeys.games_hasEnded]))
        
        ref.setValue(hasEnded) { (err, ref) in
            if let error = err {
                onError(error)
                return
            }
            
            onComplete()
        }
    }
    
    func updatePlayerHoldingItem(forGameId id: String, toItem item: AnyObject, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void) {
        guard let user = GameAuth.currentUser else { return }
        
        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, id, FirebaseKeys.games_players, user.uid, FirebaseKeys.games_players_holdingItem]))
        
        ref.runTransactionBlock({ (current) -> TransactionResult in
            guard var gameItem = current.value as? [String : String] else {
                return TransactionResult.success(withValue: current)
            }
            
            gameItem = self.convertGameItemToEncodedData(forGameItem: item)
            current.value = gameItem
            
            return TransactionResult.success(withValue: current)
        }, andCompletionBlock: { (err, committed, snap) in
            if let error = err {
                onError(error)
                return
            }
            
            onComplete()
        })
    }
    
    func updateStationItemInside(forGameId id: String, forStation station: String, toItem item: AnyObject, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void) {
        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, id, FirebaseKeys.games_stations, station, FirebaseKeys.games_stations_itemInside]))
        
        ref.runTransactionBlock({ (current) -> TransactionResult in
            guard var gameItem = current.value as? [String : String] else {
                return TransactionResult.success(withValue: current)
            }
            
            gameItem = self.convertGameItemToEncodedData(forGameItem: item)
            current.value = gameItem
            
            return TransactionResult.success(withValue: current)
        }, andCompletionBlock: { (err, committed, snap) in
            if let error = err {
                onError(error)
                return
            }
            
            onComplete()
        })
    }
    
    func handleInteractWithTable(forGameId id: String, forStation station: String, itemCarried item: MobileItem?, onItemAlreadyRemoved: @escaping () -> Void, onItemInteract: @escaping (Plate, MobileItem) -> Void, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void) {
        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, id, FirebaseKeys.games_stations, station, FirebaseKeys.games_stations_itemInside]))
        
        ref.runTransactionBlock { (current) -> TransactionResult in
            guard var itemInside = current.value as? [String : String] else {
                return TransactionResult.success(withValue: current)
            }
            
            guard let encodedString = itemInside[FirebaseKeys.games_items_encodedData], let type = itemInside[FirebaseKeys.games_items_type] else { return TransactionResult.success(withValue: current) }
            
            if type == FirebaseSystemValues.ItemTypes.none.rawValue {
//                onItemAlreadyRemoved()
                if let itemCarried = item {
                    let res = self.convertGameItemToEncodedData(forGameItem: itemCarried)

                    current.value = res
                    self .updatePlayerHoldingItem(forGameId: id, toItem: "BAH BAH" as AnyObject, { }, { (err) in
                        onError(err)
                    })
                    return TransactionResult.success(withValue: current)
                }
                self.updatePlayerHoldingItem(forGameId: id, toItem: "BOO BOO HOO" as AnyObject, { }, { (err) in
                    onError(err)
                })
                return TransactionResult.success(withValue: current)
            } else if type == FirebaseSystemValues.ItemTypes.ingredient.rawValue {
                guard let ingredient = self.decodeStringToItem(fromString: encodedString, forType: type) as? Ingredient else { return TransactionResult.success(withValue: current) }
                if let itemCarried = item as? Plate {
                    itemInside.updateValue(FirebaseSystemValues.ItemTypes.none.rawValue, forKey: FirebaseKeys.games_items_type)
                    itemInside.updateValue(FirebaseSystemValues.defaultNoItem, forKey: FirebaseKeys.games_items_encodedData)
                    self.updatePlayerHoldingItem(forGameId: id, toItem: itemCarried, { }, { (err) in
                        onError(err)
                    })
                    current.value = itemInside
                    return TransactionResult.success(withValue: current)
                }
                if let itemCarried = item as? Ingredient {
                    let res = self.convertGameItemToEncodedData(forGameItem: itemCarried)
                    self.updatePlayerHoldingItem(forGameId: id, toItem: ingredient, {}, { (err) in
                        onError(err)
                    })
                    current.value = res
                    return TransactionResult.success(withValue: current)
                }
                self.updatePlayerHoldingItem(forGameId: id, toItem: ingredient, { }, { (err) in
                    onError(err)
                })
            } else if type == FirebaseSystemValues.ItemTypes.plate.rawValue {
                guard let plate = self.decodeStringToItem(fromString: encodedString, forType: type) as? Plate else { return TransactionResult.success(withValue: current) }
                if let itemCarried = item as? Ingredient {
//                    let _ = plate.interact(withItem: itemCarried)
                    onItemInteract(plate, itemCarried)
                    let res = self.convertGameItemToEncodedData(forGameItem: plate)
                    current.value = res
                    self.updatePlayerHoldingItem(forGameId: id, toItem: "OHOHA" as AnyObject, { }, { (err) in
                        onError(err)
                    })
                    return TransactionResult.success(withValue: current)
                }
                if let itemCarried = item as? Plate {
                    let selfPlateRes = self.convertGameItemToEncodedData(forGameItem: itemCarried)
                    guard let plate = self.decodeStringToItem(fromString: encodedString, forType: type) as? Plate else { return TransactionResult.success(withValue: current) }
                    self.updatePlayerHoldingItem(forGameId: id, toItem: plate, { }, { (err) in
                        onError(err)
                    })
                    current.value = selfPlateRes
                    return TransactionResult.success(withValue: current)
                }
                self.updatePlayerHoldingItem(forGameId: id, toItem: plate, { }, { (err) in
                    onError(err)
                })
            }
            
            current.value = [FirebaseKeys.games_items_type: FirebaseSystemValues.ItemTypes.none.rawValue,
                             FirebaseKeys.games_items_encodedData: FirebaseSystemValues.defaultNoItem]
            
            return TransactionResult.success(withValue: current)
        }
    }
    
    func addScore(by addedScore: Int, forGameId id: String, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void) {
        let scoreRef = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, id, FirebaseKeys.games_score]))

        scoreRef.runTransactionBlock({ (current) -> TransactionResult in
            guard var score = current.value as? Int else {
                return TransactionResult.success(withValue: current)
            }
            
            score += addedScore
            current.value = score
            
            return TransactionResult.success(withValue: current)
        }) { (err, committed, snap) in
            if let error = err {
                onError(error)
                return
            }
            
            onComplete()
        }
    }
    
    func closeGame(forGameId id: String, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void) {
        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, id]))
        
        ref.setValue(nil) { (err, ref) in
            if let error = err {
                onError(error)
                return
            }
            
            self.closeRoom(forRoomId: id, {
                onComplete()
            }, { (err) in
                onError(err)
            })
        }
    }
    
    func addScoreToLeaderBoard(forType type: GameTypes, withName name: String, score: Int, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void) {
        let ref = dbRef.child(FirebaseKeys.scores)
        
        guard let key = ref.childByAutoId().key else { return }
        
        let scoreDict = [FirebaseKeys.scores_name: name, FirebaseKeys.scores_score: score] as [String : AnyObject]
        
        ref.child(key).setValue(scoreDict) { (err, ref) in
            if let error = err {
                onError(error)
                return
            }
            
            onComplete()
        }
    }

    func checkRejoinGame(_ onGameExist: @escaping (String) -> Void, _ onError: @escaping (Error) -> Void) {
        guard let user = GameAuth.currentUser else { return }

        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.rejoins, user.uid]))

        ref.observeSingleEvent(of: .value, with: { (snap) in
            guard let gameId = snap.value as? String else { return }
            
            let gameRef = self.dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, gameId, FirebaseKeys.games_hasEnded]))
            
            gameRef.observeSingleEvent(of: .value, with: { (snap) in
                guard let gameHasEnded = snap.value as? Bool else {
                    self.cancelRejoinGame({ }, { (err) in
                        onError(err)
                    })
                    return
                }

                if !gameHasEnded {
                    onGameExist(gameId)
                } else {
                    ref.setValue(nil, withCompletionBlock: { (err, ref) in
                        if let error = err {
                            onError(error)
                            return
                        }
                    })
                }
            }, withCancel: { (err) in
                onError(err)
            })
        }, withCancel: { (err) in
            onError(err)
        })
    }
    
    func cancelRejoinGame(_ onSuccess: @escaping () -> Void, _ onError: @escaping (Error) -> Void) {
        guard let user = GameAuth.currentUser else { return }
        
        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.rejoins, user.uid]))
        
        ref.setValue(nil) { (err, ref) in
            if let error = err {
                onError(error)
                return
            }
            
            onSuccess()
        }
    }

    func rejoinGame(forGameId id: String, _ onSuccess: @escaping (RoomModel) -> Void, _ onError: @escaping (Error) -> Void) {
        // TODO
        guard let user = GameAuth.currentUser else { return }

        let rejoinRef = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.rejoins, user.uid]))
        let roomRef = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.rooms, id]))

        rejoinRef.setValue(nil) { (err, ref) in
            if let error = err {
                onError(error)
                return
            }
            
            roomRef.observeSingleEvent(of: .value, with: { (snap) in
                guard let roomDict = snap.value as? [String : AnyObject] else { return }
                
                onSuccess(self.firebaseRoomModelFactory(forDict: roomDict))
            }, withCancel: { (err) in
                onError(err)
            })
        }
    }
    
    func updateUserOutfit(withAccessory accessory: String, withHat hat: String, withColor color: String, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void) {
        guard let user = GameAuth.currentUser else {
            return
        }
        
        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.users, user.uid]))
        
        let dict = [FirebaseKeys.users_accessory: accessory,
                                          FirebaseKeys.users_hat: hat,
        FirebaseKeys.users_color: color] as [String : AnyObject]
        
        ref.setValue(dict) { (err, ref) in
            if let error = err {
                onError(error)
                return
            }
            
            onComplete()
        }
    }
    
    func updateUserName(withName name: String, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void) {
        guard let user = GameAuth.currentUser else {
            return
        }
        
        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.users, user.uid, FirebaseKeys.users_name]))
        
        ref.setValue(name) { (err, ref) in
            if let error = err {
                onError(error)
                return
            }
            
            onComplete()
        }
    }
    
    func updateUserLevel(withLevel level: Int, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void) {
        guard let user = GameAuth.currentUser else {
            return
        }
        
        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.users, user.uid, FirebaseKeys.users_level]))
        
        ref.setValue(level) { (err, ref) in
            if let error = err {
                onError(error)
                return
            }
            
            onComplete()
        }
    }
    
    func getUserData(_ onSuccess: @escaping (UserModel) -> Void, _ onError: @escaping (Error) -> Void) {
        guard let user = GameAuth.currentUser else {
            return
        }
        
        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.users, user.uid]))
        
        ref.observeSingleEvent(of: .value, with: { (snap) in
            if let userDict = snap.value as? [String : AnyObject] {
                onSuccess(self.firebaseUserModelFactory(forDict: userDict))
                return
            }
            
            onSuccess(self.firebaseUserModelFactory(forDict: [:]))
        }) { (err) in
            onError(err)
        }
    }

    func removeAllObservers() {
        for observer in self.observers { observer.reference.removeObserver(withHandle: observer.handle) }
        observers = []
    }
    
    func removeAllDisconnectObservers() {
        for ref in self.disconnectObservers { ref.cancelDisconnectOperations() }
        disconnectObservers = []
    }
}

/**
 Implementation of Observer object using
 Firebase Realtime Database
 */
struct Observer {
    var handle: DatabaseHandle
    var reference: DatabaseReference

    init(withHandle handle: DatabaseHandle, withRef reference: DatabaseReference) {
        self.handle = handle
        self.reference = reference
    }
}
