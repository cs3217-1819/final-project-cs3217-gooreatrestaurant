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
    
    required init() {
        // add initializers
    }
    
    // MARK: Methods related to Room state
    
    func observeRoomState(forRoomId id: String, _ onDataChange: @escaping (RoomModel) -> Void, _ onRoomClose: @escaping () -> Void, _ onError: @escaping (Error) -> Void) {
        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.rooms, id]))
        
        let handle = ref.observe(.value, with: { (snap) in
            guard let roomDict = snap.value as? [String : AnyObject] else {
                // room closed or removed
                onRoomClose()
                return
            }
            
            // populate room object
            let roomName = roomDict[FirebaseKeys.rooms_roomName] as? String ?? ""
            let mapName = roomDict[FirebaseKeys.rooms_mapName] as? String ?? ""
            let roomId = roomDict[FirebaseKeys.rooms_roomId] as? String ?? ""
            let hasStarted = roomDict[FirebaseKeys.rooms_hasStarted] as? Bool ?? false
            let isOpen = roomDict[FirebaseKeys.rooms_isOpen] as? Bool ?? false
            let isGameCreated = roomDict[FirebaseKeys.rooms_isGameCreated] as? Bool ?? false
            let players = roomDict[FirebaseKeys.rooms_players] as? [String : AnyObject] ?? [:]
            
            let roomRes = RoomModel(name: roomName, map: mapName, id: roomId, hasStarted: hasStarted, gameIsCreated: isGameCreated, isOpen: isOpen)
            
            for (playerUid, playerDescription) in players {
                let isHost = playerDescription[FirebaseKeys.rooms_players_isHost] as? Bool ?? false
                let isReady = playerDescription[FirebaseKeys.rooms_players_isReady] as? Bool ?? false
                
                let player = RoomPlayerModel(uid: playerUid, isHost: isHost, isReady: isReady)
                
                roomRes.addPlayer(player)
            }
            
            onDataChange(roomRes)
        }) { (err) in
            onError(err)
        }
        
        self.observers.append(Observer(withHandle: handle, withRef: ref))
    }
    
    func joinRoom(forRoomId id: String, _ onSuccess: @escaping () -> Void, _ onRoomFull: @escaping () -> Void, _ onRoomNotExist: @escaping () -> Void, _ onGameHasStarted: @escaping () -> Void, _ onError: @escaping (Error) -> Void) {
        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.rooms, id]))
        
        guard let user = GameAuth.currentUser else {
            return
        }
        
        ref.observeSingleEvent(of: .value, with: { (snap) in
            
            guard let roomDict = snap.value as? [String : AnyObject] else {
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
            
            guard let players = roomDict[FirebaseKeys.rooms_players] as? [String : AnyObject] else {
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
            
            let newPlayerDict = self.createRoomPlayerDict(isHost: false, uid: user.uid)
            let currentUserRef = ref.child(FirebaseKeys.joinKeys([FirebaseKeys.rooms_players, user.uid]))
            
            currentUserRef.setValue(newPlayerDict[user.uid], withCompletionBlock: { (err, ref) in
                if let error = err {
                    onError(error)
                    return
                }
                
                // set disconnect flag, remove player from room
                currentUserRef.onDisconnectRemoveValue()
                
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
    /// - Returns: a dictinoary ready to be inserted
    private func createRoomPlayerDict(isHost: Bool, uid: String) -> [String : AnyObject] {
        let newPlayerDescriptionDict: [String : AnyObject] = [FirebaseKeys.rooms_players_isHost: isHost as AnyObject,
                                                              FirebaseKeys.rooms_players_isReady: isHost as AnyObject]
        
        return [uid : newPlayerDescriptionDict as AnyObject]
    }
    
    func changeRoomOpenState(forRoomId id: String, _ onError: @escaping (Error) -> Void) {
        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.rooms, id, FirebaseKeys.rooms_players_isHost]))
        
        ref.observeSingleEvent(of: .value) { (snap) in
            guard let isOpen = snap.value as? Bool else {
                return
            }
            
            ref.setValue(!isOpen, withCompletionBlock: { (err, ref) in
                if let error = err {
                    onError(error)
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
            
            ref.setValue(!isReady, withCompletionBlock: { (err, ref) in
                if let error = err {
                    onError(error)
                }
            })
        }) { (err) in
            onError(err)
        }
    }
    
    func updateRoomName(to roomName: String, forRoomId id: String, _ onError: @escaping (Error) -> Void) {
        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.rooms, id, FirebaseKeys.rooms_roomName]))
        
        ref.setValue(roomName) { (err, ref) in
            if let error = err {
                // escapes function if error
                onError(error)
                return
            }
        }
    }
    
    func createRoom(withRoomName name: String, withMap map: String, _ onSuccess: @escaping (String) -> Void, _ onError: @escaping (Error) -> Void) {
        let roomId = generateRandomId()
        
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.rooms, roomId]))
        
        ref.observeSingleEvent(of: .value, with: { (snap) in
            if snap.value as? [String : AnyObject] != nil {
                // room exists
                self.createRoom(withRoomName: name, withMap: map, { id in
                    onSuccess(id)
                }, { (err) in
                    onError(err)
                })
                
                return
            }
            
            var roomDict: [String : AnyObject] = [:]
            let playerDict: [String : AnyObject] = self.createRoomPlayerDict(isHost: true, uid: user.uid)
            
            // populates dictionary to fit the db
            roomDict.updateValue(name as AnyObject, forKey: FirebaseKeys.rooms_roomName)
            roomDict.updateValue(map as AnyObject, forKey: FirebaseKeys.rooms_mapName)
            roomDict.updateValue(roomId as AnyObject, forKey: FirebaseKeys.rooms_roomId)
            roomDict.updateValue(false as AnyObject, forKey: FirebaseKeys.rooms_hasStarted)
            roomDict.updateValue(false as AnyObject, forKey: FirebaseKeys.rooms_isGameCreated)
            roomDict.updateValue(false as AnyObject, forKey: FirebaseKeys.rooms_isOpen)
            roomDict.updateValue(playerDict as AnyObject, forKey: FirebaseKeys.rooms_players)
            
            ref.setValue(roomDict, withCompletionBlock: { (err, ref) in
                if let error = err {
                    onError(error)
                    return
                }
                
                // closes room on disconnect
                ref.onDisconnectRemoveValue()
                
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
            
            ref.setValue(nil, withCompletionBlock: { (err, ref) in
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
                ref.setValue(nil, withCompletionBlock: { (err, ref) in
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
        
        ref.observeSingleEvent(of: .value, with: { (snap) in
            //            guard let roomDict = snap.value as? [String : AnyObject] else {
            //                return
            //            }
            
            //            for (id, room) in roomDict {
            //                let roomDescriptionDict = room as? [String : AnyObject]
            //                // TODO
            //            }
        }) { (err) in
            // ah
        }
        
        return listOfRooms
    }
    
    func startGame(forRoom room: RoomModel, _ onComplete: @escaping () -> Void,_ onError: @escaping (Error) -> Void) {
        
        let hasStartedRef = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.rooms, room.id, FirebaseKeys.rooms_hasStarted]))
        let roomCreatedRef = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.rooms, room.id, FirebaseKeys.rooms_isGameCreated]))
        
        hasStartedRef.setValue(true) { (err, ref) in
            if let error = err {
                // escapes closure ir error
                onError(error)
                return
            }
            
            self.createGame(forRoom: room, {
                // sets the room created flag to true
                roomCreatedRef.setValue(true, withCompletionBlock: { (err, ref) in
                    if let error = err {
                        // escapes function on error
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
        let gameDict: [String : AnyObject] = [:]
        
        ref.setValue(gameDict) { (err, ref) in
            if let error = err {
                // escapes function on error
                onError(error)
                return
            }
            
            onComplete()
        }
    }
    
    func updatePlayerPosition(forGameId id: String, position: Int, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void) {
        guard let user = GameAuth.currentUser else {
            return
        }
        
//        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, id, FirebaseKeys.games_players, user.uid, FirebaseKeys.position]))
        // TODO
    }

    func queueOrder(forGameId id: String, withRecipe recipe: Recipe, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void) {
        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, id, FirebaseKeys.games_orders]))
        
        guard let key = ref.childByAutoId().key else { return }
        
        // TODO
        let dict = ["order": "order"]
        
        ref.child(key).setValue(dict) { (err, ref) in
            if let error = err {
                onError(error)
            }
            
            onComplete()
        }
    }

    func submitOrder(forGameId id: String, withRecipe recipe: Recipe, _ onComplete: @escaping (String?) -> Void, _ onError: @escaping (Error) -> Void) {
        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, id, FirebaseKeys.games_orders])).queryLimited(toFirst: 1).queryEqual(toValue: recipe, childKey: FirebaseKeys.games_orders_recipeName)
        
        ref.observeSingleEvent(of: .value, with: { (snap) in
            guard var dict = snap.value as? [String : AnyObject] else {
                // no recipe match
                onComplete(nil)
                return
            }
            
            if dict.count > 1 {
                onComplete(nil)
                return
            }
            
            guard let order = dict.popFirst() else {
                onComplete(nil)
                return
            }
            
            onComplete(order.key)
        }) { (err) in
            onError(err)
        }
    }
    
    func removeOrder(forGameId id: String, forOrderKey key: String, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void) {
        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, id, FirebaseKeys.games_orders, key]))
        
        ref.setValue(nil) { (err, ref) in
            if let error = err {
                onError(error)
            }
            
            onComplete()
        }
    }
    
    
    func changeRoomMap(fromRoomId id: String, toMapId mapId: String, _ onError: @escaping (Error) -> Void) {
        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.rooms, id, FirebaseKeys.rooms_mapName]))
        
        ref.setValue(mapId) { (err, ref) in
            if let error = err {
                onError(error)
            }
        }
    }
    
    func observeGameState(forGameId id: String, _ onDataChange: @escaping (GameModel) -> Void, _ onError: @escaping (Error) -> Void) {
        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.games, id]))
        
        let handle = ref.observe(.value, with: { (snap) in
            //            guard let roomDict = snap.value as? [String : AnyObject] else {
            //                return
            //            }
            
            // populate room object
            // TODO
            
            let gameRes = GameModel()
            
            onDataChange(gameRes)
        }) { (err) in
            onError(err)
        }
        
        self.observers.append(Observer(withHandle: handle, withRef: ref))
    }
    
    func checkRejoinGame(_ onGameExist: @escaping (String) -> Void, _ onError: @escaping (Error) -> Void) {
        guard let user = GameAuth.currentUser else {
            return
        }
        
        let ref = dbRef.child(FirebaseKeys.joinKeys([FirebaseKeys.rejoins, user.uid]))
        
        ref.observeSingleEvent(of: .value, with: { (snap) in
            guard let gameId = snap.value as? String else {
                return
            }
            
            onGameExist(gameId)
        }, withCancel: { (err) in
            onError(err)
        })
    }
    
    func rejoinGame(forGameId id: String, _ onSuccess: @escaping () -> Void, _ onError: @escaping (Error) -> Void) {
        // TODO
    }
    
    func removeAllObservers() {
        if observers.count <= 0 {
            return
        }
        
        for observer in self.observers {
            // remove observer handlers
            observer.reference.removeObserver(withHandle: observer.handle)
            
            // remove disconnect observers
            observer.reference.cancelDisconnectOperations()
        }
        
        observers = []
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
 a list of constants representing all the
 Firebase keys currently available. The naming
 for the constants are dependent on how deep
 the keys are in the JSON tree.
 */
struct FirebaseKeys {
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
    
    // game keys
    static let games = "games"
    static let games_gameMap = "game_map"
    static let games_hasEnded = "has_ended"
    static let games_startTime = "start_time"
    static let games_timeLimit = "time_limit"
    static let games_players = "players"
    static let games_players_isConnected = "is_connected"
    static let games_players_isReady = "is_ready"
    static let games_stations = "stations"
    //    static let games_objects = "objects"
    static let games_orders = "orders"
    static let games_orders_recipeName = "recipe_name"
    static let games_orders_issueTime = "issue_time"
    static let games_orders_timeLimit = "time_limit"
    static let games_announcements = "announcements"
    static let games_announcements_issueTime = "issue_time"
    static let games_announcements_message = "message"
    
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

