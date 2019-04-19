//
//  GameDB+Constants.swift
//  slime
//
//  Created by Johandy Tantra on 19/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

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
    static let games_players_uid = "uid"
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
    static let games_notifications = "notifications"
    static let games_notifications_description = "description"
    static let games_notifications_type = "type"
    static let games_stageItems = "stage_items"
    static let games_stageItems_uid = "uid"
    static let games_stageItems_type = "type"
    static let games_stageItems_encodedData = "encoded_data"
    static let games_stageItems_lastInteractedBy = "last_interacted_by"
    
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

enum GameTypes {
    case single
    case multiplayer
}
