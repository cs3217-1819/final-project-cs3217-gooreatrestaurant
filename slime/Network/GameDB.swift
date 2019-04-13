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
    
    /// factory function to create
    /// a RoomModel object from a firebase dictionary
    /// - Parameters:
    ///     - forDict: the dictionary fetched from
    ///       Firebase
    /// - Returns:
    ///     - a RoomModel object
    private func firebaseRoomModelFactory(forDict roomDict: [String : AnyObject]) -> RoomModel {
        // populate room object
        let roomName = roomDict[FirebaseKeys.rooms_roomName] as? String ?? FirebaseSystemValues.defaultBlankString
        let mapName = roomDict[FirebaseKeys.rooms_mapName] as? String ?? FirebaseSystemValues.defaultBlankString
        let roomId = roomDict[FirebaseKeys.rooms_roomId] as? String ?? FirebaseSystemValues.defaultBlankString
        let hasStarted = roomDict[FirebaseKeys.rooms_hasStarted] as? Bool ?? FirebaseSystemValues.defaultFalse
        let isOpen = roomDict[FirebaseKeys.rooms_isOpen] as? Bool ?? FirebaseSystemValues.defaultFalse
        let isGameCreated = roomDict[FirebaseKeys.rooms_isGameCreated] as? Bool ?? FirebaseSystemValues.defaultFalse
        let players = roomDict[FirebaseKeys.rooms_players] as? [String: AnyObject] ?? [:]
        
        let roomRes = RoomModel(name: roomName, map: mapName, id: roomId, hasStarted: hasStarted, gameIsCreated: isGameCreated, isOpen: isOpen)
        
        for (playerUid, playerDescription) in players {
            roomRes.addPlayer(self.firebaseRoomPlayerModelFactory(forUid: playerUid, forDescription: playerDescription))
        }
        
        return roomRes
    }
    
    /// factory function for RoomPlayer
    /// from a dictionary and player's uid
    /// - Parameters:
    ///     - forUid: the player's uid
    ///     - forDescription: the player's details
    /// - Returns:
    ///     - a RoomPlayerModel object
    private func firebaseRoomPlayerModelFactory(forUid uid: String, forDescription playerDescription: AnyObject) -> RoomPlayerModel {
        guard let description = playerDescription as? [String : AnyObject] else {
            return RoomPlayerModel(uid: uid, isHost: false, isReady: false)
        }
        
        let isHost = description[FirebaseKeys.rooms_players_isHost] as? Bool ?? FirebaseSystemValues.defaultFalse
        let isReady = description[FirebaseKeys.rooms_players_isReady] as? Bool ?? FirebaseSystemValues.defaultFalse
        let level = description[FirebaseKeys.rooms_players_level] as? Int ?? FirebaseSystemValues.users_defaultLevel
        let name = description[FirebaseKeys.rooms_players_name] as? String ?? FirebaseSystemValues.users_defaultName
        let hat = description[FirebaseKeys.rooms_players_hat] as? String ?? FirebaseSystemValues.users_defaultOutfit
        let accessory = description[FirebaseKeys.rooms_players_accessory] as? String ?? FirebaseSystemValues.users_defaultOutfit
        let color = description[FirebaseKeys.rooms_players_color] as? String ?? FirebaseSystemValues.users_defaultColor
        
        return RoomPlayerModel(uid: uid, isHost: isHost, isReady: isReady, name: name, color: color, hat: hat, accessory: accessory, level: level)
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

    /// crates a dictionary which translates to
    /// the firebase database reference for a
    /// player description inside a room
    /// - Parameters:
    ///     - isHost: whether user is host
    ///     - uid: the uid of the user
    ///     - forUser: the user customization object
    /// - Returns: a dictinoary ready to be inserted
    private func createRoomPlayerDict(isHost: Bool, uid: String, forUser user: UserCharacter) -> [String : AnyObject] {
        let newPlayerDescriptionDict: [String : AnyObject] = [FirebaseKeys.rooms_players_isHost: isHost as AnyObject,
            FirebaseKeys.rooms_players_isReady: isHost as AnyObject,
            FirebaseKeys.rooms_players_name: user.name as AnyObject,
            FirebaseKeys.rooms_players_level: user.level as AnyObject,
            FirebaseKeys.rooms_players_color: user.color.toString() as AnyObject,
            FirebaseKeys.rooms_players_hat: user.hat as AnyObject,
            FirebaseKeys.rooms_players_accessory: user.accessory as AnyObject]
        
        return newPlayerDescriptionDict
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

    /// generates a random 5 digit string
    /// id. This code can generate duplicates
    /// and collisions might happen
    /// - Returns: a 5 digit string id
    private func generateRandomId() -> String {
        var random: String = String(Int.random(in: 0 ..< 1000000))

        while random.count < 6 {
            random = "0\(random)"
        }

        return random
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
        gameDict.updateValue(200 as AnyObject, forKey: FirebaseKeys.games_timeLeft)
        gameDict.updateValue(NSTimeIntervalSince1970 as AnyObject, forKey: FirebaseKeys.games_startTime)
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
    
    /// generated a Firebase-ready dictionary
    /// for the stations reference inside a game
    /// - Parameters:
    ///     - forMap: the map for which the dict
    ///       is to be generated
    /// - Returns:
    ///     - a dictionary representing the stations
    private func generateStationsDict(forMap map: String) -> [String : AnyObject] {
        guard let levelDesignURL = Bundle.main.url(forResource: map, withExtension: "plist") else {
            return [:]
        }
        
        do {
            let data = try? Data(contentsOf: levelDesignURL)
            let decoder = PropertyListDecoder()
            let value = try decoder.decode(SerializableGameData.self, from: data!)
            
            return parseStationsForDecodedData(data: value)
        } catch {
            print(error.localizedDescription)
            return [:]
        }
    }
    
    /// a function that parses a decoded plist
    /// data into a Firebase-ready dictionary
    /// - Parameters:
    ///     - data: an already decoded data
    ///       of type SerializedGameData
    /// - Returns:
    ///     - a Firebase-ready dictionary for
    ///       the stations inside the game
    private func parseStationsForDecodedData(data: SerializableGameData) -> [String : AnyObject] {
        var res: [String : AnyObject] = [:]
        
        let itemInsideDict = [FirebaseKeys.games_items_type: FirebaseSystemValues.ItemTypes.none.rawValue,
                              FirebaseKeys.games_items_encodedData: FirebaseSystemValues.defaultNoItem]
        
        // table
        for (index, _) in data.table.enumerated() {
            let key = "\(FirebaseSystemValues.games_stations_table)-\(index)"
            
            let valueDict =
                [FirebaseKeys.games_stations_type: FirebaseSystemValues.games_stations_table,
                 FirebaseKeys.games_stations_isOccupied: FirebaseSystemValues.defaultFalse,
                 FirebaseKeys.games_stations_itemInside: itemInsideDict] as [String : AnyObject]
            
            res.updateValue(valueDict as AnyObject, forKey: key)
        }
        
        // frying equipment
        for (index, _) in data.fryingEquipment.enumerated() {
            let key = "\(FirebaseSystemValues.games_stations_fryingEquipment)-\(index)"
            
            let valueDict =
                [FirebaseKeys.games_stations_type: FirebaseSystemValues.games_stations_fryingEquipment,
                 FirebaseKeys.games_stations_isOccupied: FirebaseSystemValues.defaultFalse,
                 FirebaseKeys.games_stations_itemInside: itemInsideDict] as [String : AnyObject]
            
            res.updateValue(valueDict as AnyObject, forKey: key)
        }
        
        for (index, _) in data.oven.enumerated() {
            let key = "\(FirebaseSystemValues.games_stations_oven)-\(index)"
            
            let valueDict =
                [FirebaseKeys.games_stations_type: FirebaseSystemValues.games_stations_oven,
                 FirebaseKeys.games_stations_isOccupied: FirebaseSystemValues.defaultFalse,
                 FirebaseKeys.games_stations_itemInside: itemInsideDict] as [String : AnyObject]
            
            res.updateValue(valueDict as AnyObject, forKey: key)
        }
        
        for (index, _) in data.choppingEquipment.enumerated() {
            let key = "\(FirebaseSystemValues.games_stations_choppingEquipment)-\(index)"
            
            let valueDict =
                [FirebaseKeys.games_stations_type: FirebaseSystemValues.games_stations_choppingEquipment,
                 FirebaseKeys.games_stations_isOccupied: FirebaseSystemValues.defaultFalse,
                 FirebaseKeys.games_stations_itemInside: itemInsideDict] as [String : AnyObject]
            
            res.updateValue(valueDict as AnyObject, forKey: key)
        }
        
        return res
    }
    
    /// returns a key representing a coordinate
    ///  where the . is replaced with , to conform
    /// to the Firebase key nomenclature
    /// - Parameters:
    ///     - position: the position of the object
    /// - Returns:
    ///     - a string representation of the position
    ///       as a Firebase-ready key
    private func stringToPointKey(position: String) -> String {
        let position = NSCoder.cgPoint(for: position)
        return "\(position.x)+\(position.y)".replacingOccurrences(of: ".", with: ",")
    }

    /// creates a Firebase-ready dictionary
    /// for players inside a game
    /// - Parameters:
    ///     - isHost: whether the player
    ///       to be generated is the host
    /// - Returns:
    ///     - a Firebase ready dictionary
    ///       to be inserted into another dict
    private func createGamePlayersDict(forMap map: String, forPlayers players: [RoomPlayerModel]) -> [String : AnyObject] {
        guard let levelDesignURL = Bundle.main.url(forResource: map, withExtension: "plist") else {
            return [:]
        }
        
        do {
            let data = try? Data(contentsOf: levelDesignURL)
            let decoder = PropertyListDecoder()
            let value = try decoder.decode(SerializableGameData.self, from: data!)
            
            let pos = NSCoder.cgPoint(for: value.slimeInitPos)
            var playersDict: [String : AnyObject] = [:]
            
            for player in players {
                let holdingItemDict = [FirebaseKeys.games_items_type: FirebaseSystemValues.ItemTypes.none.rawValue,
                FirebaseKeys.games_items_encodedData: FirebaseSystemValues.defaultNoItem] as [String : AnyObject]
                
                let newGamePlayerDict =
                    [FirebaseKeys.games_players_isHost: player.isHost,
                     FirebaseKeys.games_players_isReady: FirebaseSystemValues.defaultFalse,
                     FirebaseKeys.games_players_isConnected: FirebaseSystemValues.defaultFalse,
                     FirebaseKeys.games_players_positionX: pos.x,
                     FirebaseKeys.games_players_positionY: pos.y,
                     FirebaseKeys.games_players_holdingItem: holdingItemDict,
                     FirebaseKeys.users_color: player.color,
                     FirebaseKeys.users_name: player.name,
                     FirebaseKeys.users_level: player.level,
                     FirebaseKeys.users_hat: player.hat,
                FirebaseKeys.users_accessory: player.accessory] as [String : AnyObject]
                
                playersDict.updateValue(newGamePlayerDict as AnyObject, forKey: player.uid)
            }
            
            return playersDict
        } catch {
            print(error.localizedDescription)
            return [:]
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
    
    private func convertPlateToEncodedData(forPlate plate: Plate) -> String? {
        let encoder = JSONEncoder()
        
        let data = try? encoder.encode(plate)
        
        guard let encodedData = data else { return nil }
        guard let res = String(data: encodedData, encoding: .utf8) else { return nil }
        
        return res
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
    
    private func convertOrderQueueToEncodedData(forOrderQueue oq: OrderQueue) -> String? {
        let encoder = JSONEncoder()
        
        let data = try? encoder.encode(oq)
        
        guard let encodedData = data else { return nil }
        guard let res = String(data: encodedData, encoding: .utf8) else { return nil }
        
        return res
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

    func observeGameState(forRoom room: RoomModel, onPlayerUpdate: @escaping (GamePlayerModel) -> Void, onStationUpdate: @escaping (String, GameStationModel) -> Void, onGameEnd: @escaping () -> Void, onOrderQueueChange: @escaping (OrderQueue) -> Void, onScoreChange: @escaping (Int) -> Void, onAllPlayersReady: @escaping () -> Void, onGameStart: @escaping () -> Void, onSelfItemChange: @escaping (ItemModel) -> Void, onTimeLeftChange: @escaping (Int) -> Void, onHostDisconnected: @escaping () -> Void, onNewOrderSubmitted: @escaping (Plate) -> Void, onComplete: @escaping () -> Void, onError: @escaping (Error) -> Void) {
        guard let user = GameAuth.currentUser else {
            return
        }
        
        let roomRef = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, room.id]))
        let playerRef = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, room.id, FirebaseKeys.games_players]))
        let scoreRef = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, room.id, FirebaseKeys.games_score]))
        let endRef = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, room.id, FirebaseKeys.games_hasEnded]))
        let hasStartedRef = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, room.id, FirebaseKeys.games_hasStarted]))
        let timeLeftRef = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, room.id, FirebaseKeys.games_timeLeft]))
        let selfHoldingItemRef = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, room.id, FirebaseKeys.games_players, user.uid, FirebaseKeys.games_players_holdingItem]))
        
        let roomHandle = roomRef.observe(.value, with: { (snap) in
            guard let _ = snap.value as? [String : AnyObject] else {
                onHostDisconnected()
                return
            }
            
            return
        }) { (err) in
            onError(err)
        }
        
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
            guard let score = snap.value as? Int else { return }
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

        let endHandle = endRef.observe(.value, with: { (snap) in
            guard let end = snap.value as? Bool else { return }
            if end { onGameEnd() }
        }) { (err) in
            onError(err)
        }

        self.observers.append(Observer(withHandle: roomHandle, withRef: roomRef))
        self.observers.append(Observer(withHandle: scoreHandle, withRef: scoreRef))
        self.observers.append(Observer(withHandle: endHandle, withRef: endRef))
        self.observers.append(Observer(withHandle: selfHandle, withRef: selfHoldingItemRef))
        self.observers.append(Observer(withHandle: timeLeftHandle, withRef: timeLeftRef))
        
        onComplete()
    }
    
    private func firebasePlateFactory(forEncodedString string: String) -> Plate? {
        let decoder = JSONDecoder()
        
        let data = string.data(using: .utf8)
        guard let decodedData = data else { return nil }
        let res = try? decoder.decode(Plate.self, from: decodedData)
        
        guard let plate = res else { return nil }
        
        return plate
    }
    
    private func generateStationIdList(fromMap map: String) -> [String] {
        guard let levelDesignURL = Bundle.main.url(forResource: map, withExtension: "plist") else {
            return []
        }
        
        var list: [String] = []
        
        do {
            let data = try? Data(contentsOf: levelDesignURL)
            let decoder = PropertyListDecoder()
            let value = try decoder.decode(SerializableGameData.self, from: data!)
            
            for (index, _) in value.choppingEquipment.enumerated() {
                list.append("\(FirebaseSystemValues.games_stations_choppingEquipment)-\(index)")
            }
            
            for (index, _) in value.fryingEquipment.enumerated() {
                list.append("\(FirebaseSystemValues.games_stations_fryingEquipment)-\(index)")
            }
            
            for (index, _) in value.table.enumerated() {
                list.append("\(FirebaseSystemValues.games_stations_table)-\(index)")
            }
            
            for (index, _) in value.oven.enumerated() {
                list.append("\(FirebaseSystemValues.games_stations_oven)-\(index)")
            }
            
            return list
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    private func firebaseOrderQueueFactory(forEncodedString string: String) -> OrderQueue? {
        let decoder = JSONDecoder()
        
        let data = string.data(using: .utf8)
        guard let decodedData = data else { return nil }
        let oq = try? decoder.decode(OrderQueue.self, from: decodedData)
        
        guard let orderQueue = oq else { return nil }
        
        return orderQueue
    }
    
    private func firebaseGameStationModelFactory(forDict stationDict: [String : AnyObject]) -> GameStationModel {
        let stationType = stationDict[FirebaseKeys.games_stations_type] as? String ?? FirebaseSystemValues.defaultNoItem
        let isOccupied = stationDict[FirebaseKeys.games_stations_isOccupied] as? Bool ?? FirebaseSystemValues.defaultFalse
        let itemInsideDict = stationDict[FirebaseKeys.games_stations_itemInside] as? [String : AnyObject] ?? [:]
        
        let itemType = itemInsideDict[FirebaseKeys.games_items_type] as? String ?? FirebaseSystemValues.ItemTypes.none.rawValue
        let encodedData = itemInsideDict[FirebaseKeys.games_items_encodedData] as? String ?? FirebaseSystemValues.defaultNoItem
        
        return GameStationModel(type: stationType, item: ItemModel(type: itemType, encodedData: encodedData), isOccupied: isOccupied)
    }
    
    private func firebaseGamePlayerModelFactory(withPlayerUid uid: String, forDict playerDict: [String : AnyObject]) -> GamePlayerModel {
        let positionX = playerDict[FirebaseKeys.games_players_positionX] as? CGFloat ?? FirebaseSystemValues.defaultCGFloat
        let positionY = playerDict[FirebaseKeys.games_players_positionY] as? CGFloat ?? FirebaseSystemValues.defaultCGFloat
        let velocityX = playerDict[FirebaseKeys.games_players_velocityX] as? CGFloat ?? FirebaseSystemValues.defaultCGFloat
        let velocityY = playerDict[FirebaseKeys.games_players_velocityY] as? CGFloat ?? FirebaseSystemValues.defaultCGFloat
        let xScale = playerDict[FirebaseKeys.games_players_xScale] as? CGFloat ?? FirebaseSystemValues.defaultCGFloat
        let isConnected = playerDict[FirebaseKeys.games_players_isConnected] as? Bool ?? FirebaseSystemValues.defaultFalse
        let isHost = playerDict[FirebaseKeys.games_players_isHost] as? Bool ?? FirebaseSystemValues.defaultFalse
        let isReady = playerDict[FirebaseKeys.games_players_isReady] as? Bool ?? FirebaseSystemValues.defaultFalse
        let name = playerDict[FirebaseKeys.users_name] as? String ?? FirebaseSystemValues.users_defaultName
        let hat = playerDict[FirebaseKeys.users_hat] as? String ?? FirebaseSystemValues.users_defaultOutfit
        let accessory = playerDict[FirebaseKeys.users_accessory] as? String ?? FirebaseSystemValues.users_defaultOutfit
        let color = playerDict[FirebaseKeys.users_color] as? String ?? FirebaseSystemValues.users_defaultColor
        let level = playerDict[FirebaseKeys.users_level] as? Int ?? FirebaseSystemValues.users_defaultLevel
        
        let holdItem = playerDict[FirebaseKeys.games_players_holdingItem] as? [String : String] ?? [:]
        let itemType = holdItem[FirebaseKeys.games_items_type] ?? FirebaseSystemValues.ItemTypes.none.rawValue
        let encodedData = holdItem[FirebaseKeys.games_items_encodedData] ?? FirebaseSystemValues.defaultNoItem
        
        return GamePlayerModel(uid: uid, posX: positionX, posY: positionY, vx: velocityX, vy: velocityY, xScale: xScale, holdingItem: ItemModel(type: itemType, encodedData: encodedData), isHost: isHost, isConnected: isConnected, isReady: isReady, name: name, hat: hat, accessory: accessory, color: color, level: level)
    }
    
    /// a utility function to find the uid of
    /// the host inside a room instance
    /// - Parameters:
    ///     - the room to be inspected
    /// - Returns:
    ///     - the uid of the host
    private func hostInRoom(_ room: RoomModel) -> String {
        for player in room.players {
            if player.isHost { return player.uid }
        }
        
        return FirebaseSystemValues.defaultBlankString
    }

    /// converts dictionary of order in Firebase
    /// to a GameOrderModel type, can return nil
    /// if result is invalid
    /// - Parameters:
    ///     - dict: a single instance of key value
    ///       pair to be transformed
    /// - Returns:
    ///     - a GameOrderModel object, nil if invalid
    private func convertOrderDictToOrder(dict: (key: String, value: AnyObject)) -> GameOrderModel? {
        guard let orderInfo = dict.value as? [String : AnyObject] else {
            return nil
        }

        let issueTime = orderInfo[FirebaseKeys.games_orders_issueTime] as? Double ?? 0.0
        let timeLimit = orderInfo[FirebaseKeys.games_orders_timeLimit] as? Double ?? 0.0
        let name = orderInfo[FirebaseKeys.games_orders_encodedRecipe] as? String ?? ""

        return GameOrderModel(id: dict.key, name: name, issueTime: issueTime, timeLimit: timeLimit)
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
    
    private func convertGameItemToEncodedData(forGameItem item: AnyObject) -> [String : String] {
        var resultingDict = [FirebaseKeys.games_items_type: FirebaseSystemValues.ItemTypes.none.rawValue,
                             FirebaseKeys.games_items_encodedData: FirebaseSystemValues.defaultNoItem]
        
        let encoder = JSONEncoder()
        
        if let ingredient = item as? Ingredient {
            let data = try? encoder.encode(ingredient)
            guard let result = data else { return resultingDict }
            guard let encodedItem = String(data: result, encoding: .utf8) else { return resultingDict }
            
            resultingDict.updateValue(FirebaseSystemValues.ItemTypes.ingredient.rawValue, forKey: FirebaseKeys.games_items_type)
            resultingDict.updateValue(encodedItem, forKey: FirebaseKeys.games_items_encodedData)
        }
        
        if let plate = item as? Plate {
            let data = try? encoder.encode(plate)
            guard let result = data else { return resultingDict }
            guard let encodedItem = String(data: result, encoding: .utf8) else { return resultingDict }
            
            resultingDict.updateValue(FirebaseSystemValues.ItemTypes.plate.rawValue, forKey: FirebaseKeys.games_items_type)
            resultingDict.updateValue(encodedItem, forKey: FirebaseKeys.games_items_encodedData)
        }
        
        return resultingDict
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
                guard let gameHasEnded = snap.value as? Bool else { return }

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
    
    func updateUserNmae(withName name: String, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void) {
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
    
    /// factory method to generate user model
    /// from a firebase dictionary
    /// - Parameters:
    ///     - forDict: the dictionary pulled from
    ///       firebase for a user object
    /// - Returns:
    ///     - a UserModel object representing the dictionary
    private func firebaseUserModelFactory(forDict dict: [String : AnyObject]) -> UserModel {
        let name = dict[FirebaseKeys.users_name] as? String ?? FirebaseSystemValues.users_defaultName
        let hat = dict[FirebaseKeys.users_hat] as? String ?? FirebaseSystemValues.users_defaultOutfit
        let accessory = dict[FirebaseKeys.users_accessory] as? String ?? FirebaseSystemValues.users_defaultOutfit
        let color = dict[FirebaseKeys.users_hat] as? String ?? FirebaseSystemValues.users_defaultColor
        let level = dict[FirebaseKeys.users_level] as? Int ?? FirebaseSystemValues.users_defaultLevel
        
        return UserModel(name: name, level: level, hat: hat, accessory: accessory, color: color)
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

/**
 serializes item types in game to JSON strings
 **/
struct ItemSerializer {
    static func serializeItem(forItem item: AnyObject, withType type: String) -> String {
        switch (type) {
        case FirebaseSystemValues.ItemTypes.plate.rawValue:
            // serialize to plate
            return ""
        case FirebaseSystemValues.ItemTypes.ingredient.rawValue:
            // serialize to ingredient
            return ""
        default:
            // return none
            return ""
        }
    }
    
    static func deserializeItem(forData data: String) -> (type: String, item: AnyObject) {
        return (type: "", item: "hello" as AnyObject)
    }
}

enum GameTypes {
    case single
    case multiplayer
}

struct FirebaseSystemValues {
    // game values
    static let games_stations_fryingEquipment = "fryingEquipment"
    static let games_stations_oven = "oven"
    static let games_stations_table = "table"
    static let games_stations_storeFront = "storeFront"
    static let games_stations_choppingEquipment = "choppingEquipment"
    static let games_stations_plateStorage = "plateStorage"
    static let games_stations_trashBin = "trashBin"
    
    static let users_defaultOutfit = "none"
    static let users_defaultName = "Generic Slime"
    static let users_defaultColor = "green"
    static let users_defaultLevel = 1
    
    static let defaultFalse = false
    static let defaultBlankString = ""
    static let defaultNoItem = "none"
    static let defaultDouble = 0.0
    static let defaultCGFloat = 0.0 as CGFloat
    
    enum ItemTypes: String {
        case none
        case plate
        case ingredient
    }
}

/**
 a list of constants representing all the
 Firebase keys currently available. The naming
 for the constants are dependent on how deep
 the keys are in the JSON tree.
 */
struct FirebaseKeys {
    // user keys
    static let users = "users"
    static let users_name = "name"
    static let users_color = "color"
    static let users_hat = "hat"
    static let users_accessory = "accessory"
    static let users_level = "level"
    static let users_exp = "exp"
    
    // room keys
    static let rooms = "rooms"
    static let rooms_roomName = "room_name"
    static let rooms_mapName = "map_name"
    static let rooms_roomId = "room_id"
    static let rooms_hasStarted = "has_started"
    static let rooms_isOpen = "is_open"
    static let rooms_isGameCreated = "is_game_created"
    static let rooms_players = "players"
    static let rooms_players_isReady = "is_ready"
    static let rooms_players_isHost = "is_host"
    static let rooms_players_name = "name"
    static let rooms_players_level = "level"
    static let rooms_players_hat = "hat"
    static let rooms_players_color = "color"
    static let rooms_players_accessory = "accessory"

    // game keys
    static let games = "games"
    static let games_gameMap = "game_map"
    static let games_hasEnded = "has_ended"
    static let games_hasStarted = "has_started"
    static let games_startTime = "start_time"
    static let games_timeLeft = "time_left"
    static let games_players = "players"
    static let games_players_isHost = "is_host"
    static let games_players_isConnected = "is_connected"
    static let games_players_isReady = "is_ready"
    static let games_players_holdingItem = "holding_item"
    static let games_players_positionX = "position_x"
    static let games_players_positionY = "position_y"
    static let games_players_velocityX = "velocity_x"
    static let games_players_velocityY = "velocity_y"
    static let games_players_xScale = "x_scale"
    static let games_score = "score"
    static let games_stations = "stations"
    static let games_stations_itemInside = "item_inside"
    static let games_stations_isOccupied = "is_occupied"
    static let games_stations_type = "type"
    static let games_items_type = "type"
    static let games_items_encodedData = "encoded_data"
    //    static let games_objects = "objects"
    static let games_orderQueue = "order_queue"
    static let games_ordersSubmitted = "orders_submitted"
    static let games_orders_encodedRecipe = "encoded_recipe"
    static let games_orders_issueTime = "issue_time"
    static let games_orders_timeLimit = "time_limit"
    static let games_announcements = "announcements"
    static let games_announcements_issueTime = "issue_time"
    static let games_announcements_message = "message"
    
    // leaderboard stuff
    static let scores = "scores"
    static let scores_name = "scores_name"
    static let scores_score = "scores_score"

    // rejoin keys
    static let rejoins = "rejoins"

    /// joins keys with the required separator
    /// - Parameters:
    ///     - forKeys: an array of keys
    /// - Returns:
    ///     - a String representing the joined keys
    static func joinKeys(_ keys: [String]) -> String {
        var finalReference = ""

        for key in keys {
            finalReference = "\(finalReference)/\(key)"
        }

        return finalReference
    }
}
