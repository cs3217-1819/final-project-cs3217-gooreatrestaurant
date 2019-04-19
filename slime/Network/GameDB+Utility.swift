//
//  GameDB+Utility.swift
//  slime
//
//  Created by Johandy Tantra on 19/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

extension GameDB {
    
    // MARK: helper functions
    
    /// a utility function to find the uid of
    /// the host inside a room instance
    /// - Parameters:
    ///     - the room to be inspected
    /// - Returns:
    ///     - the uid of the host
    func hostInRoom(_ room: RoomModel) -> String {
        for player in room.players {
            if player.isHost { return player.uid }
        }
        
        return FirebaseSystemValues.defaultBlankString
    }
    
    /// generates a random 5 digit string
    /// id. This code can generate duplicates
    /// and collisions might happen
    /// - Returns: a 5 digit string id
    func generateRandomId() -> String {
        var random: String = String(Int.random(in: 0 ..< 1000000))
        
        while random.count < 6 {
            random = "0\(random)"
        }
        
        return random
    }
    
    func generateStationIdList(fromMap map: String) -> [String] {
        let level = LevelsReader.getLevel(id: map)
        guard let plistFileName = level?.fileName else { return [] }
        
        guard let levelDesignURL = Bundle.main.url(forResource: plistFileName, withExtension: "plist") else {
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
    
    /// a function that parses a decoded plist
    /// data into a Firebase-ready dictionary
    /// - Parameters:
    ///     - data: an already decoded data
    ///       of type SerializedGameData
    /// - Returns:
    ///     - a Firebase-ready dictionary for
    ///       the stations inside the game
    func parseStationsForDecodedData(data: SerializableGameData) -> [String : AnyObject] {
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
    
    // MARK: factory helper functions
    
    /// factory function to create
    /// a RoomModel object from a firebase dictionary
    /// - Parameters:
    ///     - forDict: the dictionary fetched from
    ///       Firebase
    /// - Returns:
    ///     - a RoomModel object
    func firebaseRoomModelFactory(forDict roomDict: [String : AnyObject]) -> RoomModel {
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
    
    /// factory method to generate user model
    /// from a firebase dictionary
    /// - Parameters:
    ///     - forDict: the dictionary pulled from
    ///       firebase for a user object
    /// - Returns:
    ///     - a UserModel object representing the dictionary
    func firebaseUserModelFactory(forDict dict: [String : AnyObject]) -> UserModel {
        let name = dict[FirebaseKeys.users_name] as? String ?? FirebaseSystemValues.users_defaultName
        let hat = dict[FirebaseKeys.users_hat] as? String ?? FirebaseSystemValues.users_defaultOutfit
        let accessory = dict[FirebaseKeys.users_accessory] as? String ?? FirebaseSystemValues.users_defaultOutfit
        let color = dict[FirebaseKeys.users_hat] as? String ?? FirebaseSystemValues.users_defaultColor
        let level = dict[FirebaseKeys.users_level] as? Int ?? FirebaseSystemValues.users_defaultLevel
        
        return UserModel(name: name, level: level, hat: hat, accessory: accessory, color: color)
    }
    
    /// factory function for RoomPlayer
    /// from a dictionary and player's uid
    /// - Parameters:
    ///     - forUid: the player's uid
    ///     - forDescription: the player's details
    /// - Returns:
    ///     - a RoomPlayerModel object
    func firebaseRoomPlayerModelFactory(forUid uid: String, forDescription playerDescription: AnyObject) -> RoomPlayerModel {
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

    func firebaseStageItemModelFactory(fromData data: [String : String]) -> StageItemModel {
        let encodedData = data[FirebaseKeys.games_stageItems_encodedData] ?? ""
        let type = data[FirebaseKeys.games_stageItems_type] ?? ""
        let uid = data[FirebaseKeys.games_stageItems_uid] ?? ""
        let lastInteractedBy = data[FirebaseKeys.games_stageItems_lastInteractedBy] ?? ""
        
        return StageItemModel(uid: uid, encodedData: encodedData, type: type, lastInteractedBy: lastInteractedBy)
    }
    
    func firebaseNotificationModelFactory(forData data: [String : String]) -> NotificationModel {
        let description = data[FirebaseKeys.games_notifications_description] ?? ""
        let type = data[FirebaseKeys.games_notifications_type] ?? "info"
        
        return NotificationModel(description: description, type: type)
    }
    
    func firebasePlateFactory(forEncodedString string: String) -> Plate? {
        let decoder = JSONDecoder()
        
        let data = string.data(using: .utf8)
        guard let decodedData = data else { return nil }
        let res = try? decoder.decode(Plate.self, from: decodedData)
        
        guard let plate = res else { return nil }
        
        return plate
    }
    
    func firebaseOrderQueueFactory(forEncodedString string: String) -> OrderQueue? {
        let decoder = JSONDecoder()
        
        let data = string.data(using: .utf8)
        guard let decodedData = data else { return nil }
        let oq = try? decoder.decode(OrderQueue.self, from: decodedData)
        
        guard let orderQueue = oq else { return nil }
        
        return orderQueue
    }
    
    func firebaseGameStationModelFactory(forDict stationDict: [String : AnyObject]) -> GameStationModel {
        let stationType = stationDict[FirebaseKeys.games_stations_type] as? String ?? FirebaseSystemValues.defaultNoItem
        let isOccupied = stationDict[FirebaseKeys.games_stations_isOccupied] as? Bool ?? FirebaseSystemValues.defaultFalse
        let itemInsideDict = stationDict[FirebaseKeys.games_stations_itemInside] as? [String : AnyObject] ?? [:]
        
        let itemType = itemInsideDict[FirebaseKeys.games_items_type] as? String ?? FirebaseSystemValues.ItemTypes.none.rawValue
        let encodedData = itemInsideDict[FirebaseKeys.games_items_encodedData] as? String ?? FirebaseSystemValues.defaultNoItem
        
        return GameStationModel(type: stationType, item: ItemModel(type: itemType, encodedData: encodedData), isOccupied: isOccupied)
    }
    
    func firebaseGamePlayerModelFactory(withPlayerUid uid: String, forDict playerDict: [String : AnyObject]) -> GamePlayerModel {
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
    
    /// converts dictionary of order in Firebase
    /// to a GameOrderModel type, can return nil
    /// if result is invalid
    /// - Parameters:
    ///     - dict: a single instance of key value
    ///       pair to be transformed
    /// - Returns:
    ///     - a GameOrderModel object, nil if invalid
    func convertOrderDictToOrder(dict: (key: String, value: AnyObject)) -> GameOrderModel? {
        guard let orderInfo = dict.value as? [String : AnyObject] else {
            return nil
        }
        
        let issueTime = orderInfo[FirebaseKeys.games_orders_issueTime] as? Double ?? 0.0
        let timeLimit = orderInfo[FirebaseKeys.games_orders_timeLimit] as? Double ?? 0.0
        let name = orderInfo[FirebaseKeys.games_orders_encodedRecipe] as? String ?? ""
        
        return GameOrderModel(id: dict.key, name: name, issueTime: issueTime, timeLimit: timeLimit)
    }
    
    // MARK: conversions
    
    /// crates a dictionary which translates to
    /// the firebase database reference for a
    /// player description inside a room
    /// - Parameters:
    ///     - isHost: whether user is host
    ///     - uid: the uid of the user
    ///     - forUser: the user customization object
    /// - Returns: a dictinoary ready to be inserted
    func createRoomPlayerDict(isHost: Bool, uid: String, forUser user: UserCharacter) -> [String : AnyObject] {
        let newPlayerDescriptionDict: [String : AnyObject] = [FirebaseKeys.rooms_players_isHost: isHost as AnyObject,
            FirebaseKeys.rooms_players_isReady: isHost as AnyObject,
            FirebaseKeys.rooms_players_name: user.name as AnyObject,
            FirebaseKeys.rooms_players_level: user.level as AnyObject,
            FirebaseKeys.rooms_players_color: user.color.toString() as AnyObject,
            FirebaseKeys.rooms_players_hat: user.hat as AnyObject,
            FirebaseKeys.rooms_players_accessory: user.accessory as AnyObject]
        
        return newPlayerDescriptionDict
    }
    
    /// generated a Firebase-ready dictionary
    /// for the stations reference inside a game
    /// - Parameters:
    ///     - forMap: the map for which the dict
    ///       is to be generated
    /// - Returns:
    ///     - a dictionary representing the stations
    func generateStationsDict(forMap map: String) -> [String : AnyObject] {
        let level = LevelsReader.getLevel(id: map)
        guard let fileName = level?.fileName else { return [:] }
        
        guard let levelDesignURL = Bundle.main.url(forResource: fileName, withExtension: "plist") else {
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
    
    /// creates a Firebase-ready dictionary
    /// for players inside a game
    /// - Parameters:
    ///     - isHost: whether the player
    ///       to be generated is the host
    /// - Returns:
    ///     - a Firebase ready dictionary
    ///       to be inserted into another dict
    func createGamePlayersDict(forMap map: String, forPlayers players: [RoomPlayerModel]) -> [String : AnyObject] {
        let level = LevelsReader.getLevel(id: map)
        guard let fileName = level?.fileName else { return [:] }
        
        guard let levelDesignURL = Bundle.main.url(forResource: fileName, withExtension: "plist") else {
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
                    [FirebaseKeys.games_players_uid: player.uid,
                     FirebaseKeys.games_players_isHost: player.isHost,
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
    
    // MARK: encode decode
    
    func convertPlateToEncodedData(forPlate plate: Plate) -> String? {
        let encoder = JSONEncoder()
        
        let data = try? encoder.encode(plate)
        
        guard let encodedData = data else { return nil }
        guard let res = String(data: encodedData, encoding: .utf8) else { return nil }
        
        return res
    }
    
    func encodePlateToString(withPlate plate: Plate) -> String? {
        let encoder = JSONEncoder()
        
        let data = try? encoder.encode(plate)
        guard let encodedData = data else { return nil }
        let string = String(data: encodedData, encoding: .utf8)
        guard let res = string else { return nil }
        
        return res
    }
    
    func convertEncodedDataToPlate(withEncodedData string: String) -> Plate? {
        let decoder = JSONDecoder()
        
        guard let data = string.data(using: .utf8) else { return nil }
        let encodedPlate = try? decoder.decode(Plate.self, from: data)
        guard let plate = encodedPlate else { return nil }
        
        return plate
    }
    
    func convertStageItemToEncodedData(withUid uid: String, withItem item: AnyObject) -> [String : String]? {
        guard let userUid = GameAuth.currentUser?.uid else { return nil }
        let encoder = JSONEncoder()
        
        if let ingredient = item as? Ingredient {
            let data = try? encoder.encode(ingredient)
            guard let result = data else { return nil }
            guard let encodedItem = String(data: result, encoding: .utf8) else { return nil }
            
            return [FirebaseKeys.games_stageItems_uid: uid,
                    FirebaseKeys.games_stageItems_type: FirebaseSystemValues.ItemTypes.ingredient.rawValue,
                    FirebaseKeys.games_stageItems_encodedData: encodedItem,
                    FirebaseKeys.games_stageItems_lastInteractedBy: userUid]
        }
        
        if let plate = item as? Plate {
            let data = try? encoder.encode(plate)
            guard let result = data else { return nil }
            guard let encodedItem = String(data: result, encoding: .utf8) else { return nil }
            
            return [FirebaseKeys.games_stageItems_uid: uid,
                    FirebaseKeys.games_stageItems_type: FirebaseSystemValues.ItemTypes.plate.rawValue,
                    FirebaseKeys.games_stageItems_encodedData: encodedItem,
                    FirebaseKeys.games_stageItems_lastInteractedBy: userUid]
        }
        
        return nil
    }
    
    func convertEncodedDataToMobileItem(forString string: String) -> MobileItem? {
        let decoder = JSONDecoder()
        
        guard let data = string.data(using: .utf8) else { return nil }
        let plate = try? decoder.decode(Plate.self, from: data)
        
        if let res = plate {
            return res as MobileItem
        }
        
        let ingredient = try? decoder.decode(Ingredient.self, from: data)
        
        if let res = ingredient {
            return res as MobileItem
        }
        
        return nil
    }
    
    func convertOrderQueueToEncodedData(forOrderQueue oq: OrderQueue) -> String? {
        let encoder = JSONEncoder()
        
        let data = try? encoder.encode(oq)
        
        guard let encodedData = data else { return nil }
        guard let res = String(data: encodedData, encoding: .utf8) else { return nil }
        
        return res
    }
    
    func decodeStringToItem(fromString string: String, forType type: String) -> AnyObject? {
        let decoder = JSONDecoder()
        let encodedData = string.data(using: .utf8)
        guard let data = encodedData else { return nil }
        
        if type == FirebaseSystemValues.ItemTypes.ingredient.rawValue {
            let ingredient = try? decoder.decode(Ingredient.self, from: data)
            guard let res = ingredient else { return nil }
            return res
        }
        
        if type == FirebaseSystemValues.ItemTypes.plate.rawValue {
            let plate = try? decoder.decode(Plate.self, from: data)
            guard let res = plate else { return nil }
            return res
        }
        
        return nil
    }
    
    func convertGameItemToEncodedData(forGameItem item: AnyObject) -> [String : String] {
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
}
