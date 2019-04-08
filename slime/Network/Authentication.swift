//
//  GameAuthentication.swift
//  slime
//
//  Created by Johandy Tantra on 25/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import Firebase

/**
 An interface for a simple anonymous
 game authentication.
 */
protocol GameAuthentication {

    /// listens to changes in authentication
    /// states, the closure will be fired when
    /// user either successfully logs in or
    /// user logs out
    /// - Parameters:
    ///     - onStateChange: a closure run when
    ///       the auth state for the current user
    ///       changes
    static func listenToAuthStateChange(_ onStateChange: @escaping (User) -> Void)

    /// the current user tied to the anonymous authentication
    /// specific to the machine
    static var currentUser: User? { get }

    /// signs in anonymously, the account
    /// is tied to the machine, but is refreshed
    /// after application is removed from the
    /// machine
    /// - Parameters:
    ///     - onError: a closure run after an error
    ///       occurs
    static func signInAnonymously(_ onError: @escaping (Error) -> Void)
}

class GameAuth: GameAuthentication {
    public static func listenToAuthStateChange(_ onStateChange: @escaping (User) -> Void) {
        Auth.auth().addStateDidChangeListener { (_, user) in
            if let user = user {
                onStateChange(user)
            }
        }
    }

    public static var currentUser: User? {
        guard let user = Auth.auth().currentUser else {
            return nil
        }

        return user
    }

    public static func signInAnonymously(_ onError: @escaping (Error) -> Void) {
        Auth.auth().signInAnonymously { (_, err) in
            if let error = err {
                onError(error)
            }
        }
    }
}
