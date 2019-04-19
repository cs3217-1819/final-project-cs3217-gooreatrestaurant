//
//  GameAuth.swift
//  slime
//
//  Created by Johandy Tantra on 19/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import Foundation

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
