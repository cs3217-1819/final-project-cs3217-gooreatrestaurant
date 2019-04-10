//
//  GameDatabase.swift
//  slime
//
//  Created by Johandy Tantra on 25/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

/**
 Abstraction class for the game database. Contains
 methods to create listeners or return information
 from the database. This database is attached to
 the current user.
 */
protocol GameDatabase {

    /// all available observers inside
    /// the database itself
    var observers: [Observer] { get }

    init()

    /// creates a listener for a room instance and
    /// includes a closure with the Room object.
    /// This listener is fired every time any child
    /// is changed in this node.
    /// - Parameters:
    ///     - forRoomId: the room name this listener
    ///       is listening to
    ///     - onDataChange: an escaping closure fired every
    ///       change in child of the room
    ///     - onError: a block run after an error happens
    func observeRoomState(forRoomId id: String, _ onDataChange: @escaping (RoomModel) -> Void, _ onRoomClose: @escaping () -> Void, _ onError: @escaping (Error) -> Void)

    /// joins a room and creates a reference
    /// to the players list inside the room
    /// itself
    /// - Parameters:
    ///     - forRoomId: the room id to be joined
    ///     - onSuccess: a closure performed after
    ///       join room is successful
    ///     - onRoomFull: a closure fired when the
    ///       room is already full
    ///     - onGameHasStarted: a closure fired when
    ///       the room has already started the game
    ///     - onError: a closure fired when an error
    ///       occurs
    func joinRoom(forRoomId id: String, _ onSuccess: @escaping () -> Void, _ onRoomFull: @escaping () -> Void, _ onRoomNotExist: @escaping () -> Void, _ onGameHasStarted: @escaping () -> Void, _ onError: @escaping (Error) -> Void)

    /// opens or closes a room so it can be shown to
    /// everyone. this method will flip the
    /// room state in the database.
    /// - Parameters:
    ///     - forRoomId: the room id to be opened
    ///     - onError: closure run after an error
    ///       happens
    func changeRoomOpenState(forRoomId id: String, _ onError: @escaping (Error) -> Void)

    /// changes the ready state for the current
    /// user in the room
    /// - Parameters:
    ///     - forRoomId: the room id specified
    ///     - onComplete: the closure run after
    ///       every process is completed
    ///     - onError: a closure run when an error
    ///       occurs
    func changeReadyState(forRoomId id: String, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void)

    /// updates the room name for the specified
    /// room ID.
    /// - Parameters:
    ///     - roomName: the new room name to be
    ///       changed to
    ///     - forRoomId: the room ID which name is
    ///       to be changed
    ///     - onError: a block executed after an error
    ///       happens
    func updateRoomName(to roomName: String, forRoomId id: String, _ onError: @escaping (Error) -> Void)

    /// gets all rooms which are open to public
    /// with a specified count
    /// - Parameters:
    ///     - count: the max number of rooms to be
    ///       fetched
    ///     - onError: a closure run after an error
    ///       occurs
    /// - Returns:
    ///     - An array of RoomModel listing open rooms
    func getOpenRooms(limitTo count: Int, _ onError: @escaping (Error) -> Void) -> [RoomModel]

    /// creates a room instance in the firebase
    /// to connect to. This method will generate
    /// a short unique ID and returns it when called
    /// this ID is used for listening to room changes
    /// - Parameters:
    ///     - withRoomName: the name of the room to be
    ///       be created
    ///     - withMap: the map name this room is set
    ///     - onSuccess: a closure run on success, passing
    ///       the room id as the parameter
    ///     - onError: completion block run when error happens
    func createRoom(withRoomName name: String, withMap map: String, _ onSuccess: @escaping (String) -> Void, _ onError: @escaping (Error) -> Void)

    /// closes a particular room, removing its
    /// reference in the database
    /// - Parameters:
    ///     - forRoomId: the room id to be closed
    ///     - onComplete: a completion block for this method
    ///     - onError: a closure executed when an error occurs
    func closeRoom(forRoomId id: String, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void)

    /// leaves a particular room, removing
    /// the user reference in the db
    /// - Parameters:
    ///     - fromRoomId: the room id
    ///     - onComplete: a completion block run
    ///       after method is complete
    ///     - onError: a closure run when an error
    ///       occurs
    func leaveRoom(fromRoomId id: String, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void)

    /// changes a room's map id
    /// - Parameters:
    ///     - fromRoomId: the room id the map
    ///       is to be changed
    ///     - toMapId: the map id to be changed
    ///     - onError: a closure run when an error occurs
    func changeRoomMap(fromRoomId id: String, toMapId mapId: String, _ onError: @escaping (Error) -> Void)

    // MARK: Methods related to Game state

    /// starts a game instance for a particular room
    /// This method only changes the state of the room
    /// to ready and creates a reference to the game
    /// in the database itself, before calling on onComplete
    /// - Parameters:
    ///     - forRoom: the room that the game is to be started
    ///     - onComplete: a completion block run after a successful
    ///       game start
    ///     - onError: a block executed when an error happens
    func startGame(forRoom room: RoomModel, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void)

    /// sets the player's state to ready inside the
    /// game instance so that the host can start the
    /// game proper
    /// - Parameters:
    ///     - forGameId: the game id
    ///     - onComplete: a closure run after completion
    ///       of this update
    ///     - onError: a closure run when an error occurs
    func joinGame(forGameId id: String, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void)

    /// creates a game database reference to the
    /// specified room.
    /// - Parameters:
    ///     - forRoom: the specified room for which
    ///       the game is to be created
    ///     - onComplete: completion block run after
    ///       successful completion of the method
    ///     - onError: block run when an error happens
    func createGame(forRoom room: RoomModel, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void)

    /// attaches a listener to the game reference
    /// the onDataChange is fired whenever a change
    /// in the game state is observed
    /// - Parameters:
    ///     - forGameId: the game id to be observed
    ///     - onDataChange: a closure which is fired
    ///       every time a data value changes
    ///     - onError: fired when an error happens
    func observeGameState(forRoom room: RoomModel, onPlayerUpdate: @escaping (GamePlayerModel) -> Void, onStationUpdate: @escaping () -> Void, onGameEnd: @escaping () -> Void, onOrderChange: @escaping ([GameOrderModel]) -> Void, onScoreChange: @escaping (Int) -> Void, onAllPlayersReady: @escaping () -> Void, onError: @escaping (Error) -> Void)

    /// updates a player position inside the game
    /// id specified inside this method
    /// - Parameters:
    ///     - forGameId: the game id for which the
    ///       position of the player is to updated
    ///     - position: the position of the player
    func updatePlayerPosition(forGameId id: String, position: CGPoint, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void)

    /// adds an order to the end of the current list
    /// of orders
    /// - Parameters:
    ///     - forGameId: the game id for which the order
    ///       is to be queued
    ///     - withRecipe: the recipe of the order to be queued
    ///     - onComplete: a closure run after this
    ///       method has completed
    ///     - onError: a closure run when this method
    ///       throws an error
    func queueOrder(forGameId id: String, withRecipe recipe: Recipe, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void)

    /// submits an order to be compared with the list of
    /// available orders, returning the earliest possible
    /// match.
    /// - Parameters:
    ///     - forGameId: the game id for which the order
    ///       is to be submitted to
    ///     - withRecipe: the recipe of the order to be submitted
    ///     - onComplete: completion block with a string
    ///       representing the order key, nil if there is no
    ///       match
    ///     - onError: an closure block run when an error
    ///       occurs
    func submitOrder(forGameId id: String, withRecipe recipe: Recipe, _ onComplete: @escaping (String?) -> Void, _ onError: @escaping (Error) -> Void)

    /// removes an order from the current list of orders
    /// wtih a specified key
    /// - Parameters:
    ///     - forGameId: the game id for which the order is
    ///       to be removed
    ///     - forOrderKey: the key for the order
    ///     - onComplete: completion block after successful
    ///       removal
    ///     - onError: a closure run when an error occurs
    func removeOrder(forGameId id: String, forOrderKey key: String, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void)

    // MARK: Other methods

    /// checks whether a game exists for rejoin
    /// if a game exists, then it will return a closure
    /// with the game id string passed through the
    /// closure
    /// - Parameters:
    ///     - onGameExist: a closure fired when there
    ///       exists a game for the user to rejoin
    ///     - onError: a closure fired when an error
    ///       occurs
    func checkRejoinGame(_ onGameExist: @escaping (String) -> Void, _ onError: @escaping (Error) -> Void)

    /// rejoins a game
    /// - Parameters:
    ///     - forGameId: the game id to reconnect to
    ///     - onSuccess: closure run after successful
    ///       rejoin
    ///     - onError: closure run when an error occurs
    func rejoinGame(forGameId id: String, _ onSuccess: @escaping () -> Void, _ onError: @escaping (Error) -> Void)
    
    /// updates own user's outfit for hats, color
    /// and accessories
    /// - Parameters:
    ///     - withAccessory: the accessory to be changed to
    ///     - withHat: the hat to be changed to
    ///     - withColor: the color to be changed to
    ///     - onComplete: a completion block run after the update
    ///       is successful
    ///     - onError: an error block run when an error occurs
    func updateUserOutfit(withAccessory accessory: String, withHat hat: String, withColor color: String, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void)
    
    /// updates own user's name
    /// - Parameters:
    ///     - withName: the name to be changed to
    ///     - onComplete: closure when this block completes
    ///     - onError: closure run when an error occurs
    func updateUserNmae(withName name: String, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void)
    
    /// updates own user's level
    /// - Parameters:
    ///     - withLevel: the level to be changed to
    ///     - onComplete: closure when update is successful
    ///     - onError: closure run when an error occurs
    func updateUserLevel(withLevel level: Int, _ onComplete: @escaping () -> Void, _ onError: @escaping (Error) -> Void)
    
    /// gets current user's data in the db,
    /// name defaults to "Generic Slime",
    /// level 1, color "green", hat "none",
    /// and accessory "none"
    /// - Parameters:
    ///     - onSuccess: a closure with the user
    ///       model inside the params run when
    ///       the query is a success
    ///     - onError: a closure run when an error
    ///       occurs
    func getUserData(_ onSuccess: @escaping (UserModel) -> Void, _ onError: @escaping (Error) -> Void)

    /// removes all observers inside the game
    /// database.
    func removeAllObservers()
}
