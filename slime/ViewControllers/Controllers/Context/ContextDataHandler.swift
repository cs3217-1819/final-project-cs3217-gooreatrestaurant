//
//  ContextDataHandler.swift
//  slime
//
//  Created by Gabriel Tan on 3/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import Foundation
import RxSwift

// Handles local data.
class ContextDataHandler {
    private let disposeBag = DisposeBag()
    private(set) var userCharacter: BehaviorSubject<UserCharacter>?

    init() {
        setupAutosaveCharacter()
    }

    // Creates a character and saves it.
    func createCharacter(named name: String, color: SlimeColor) {
        let char = UserCharacter(named: name)
        char.set(color: color)
        userCharacter = BehaviorSubject(value: char)
        setupAutosaveCharacter()
        Logger.it.info("Created character")
    }

    // Load user data from storage and saves it for later use.
    func loadUserData() {
        guard let character = LocalData.it.getUserCharacter() else {
            return
        }
        Logger.it.info("Loading character \(character.name)")
        if let trueCharacter = userCharacter {
            // character already loaded
            trueCharacter.onNext(character)
        } else {
            // create it
            userCharacter = BehaviorSubject(value: character)
            setupAutosaveCharacter()
        }
    }

    // Method to gain local character EXP.
    func gainCharacterExp(_ exp: Int) {
        guard let char = getChar() else {
            return
        }
        char.gainExp(exp)
        userCharacter?.onNext(char)
    }

    // Method to change the local character's colour.
    func changeCharacterColor(_ color: SlimeColor) {
        guard let char = getChar() else {
            return
        }
        char.set(color: color)
        userCharacter?.onNext(char)
    }
    
    // Method to change the local character's hat.
    func changeHat(_ name: String) {
        guard let char = getChar() else {
            return
        }
        char.setHat(name)
        userCharacter?.onNext(char)
    }
    
    // Method to change the local characetr's accessory.
    func changeAccessory(_ name: String) {
        guard let char = getChar() else {
            return
        }
        char.setAccessory(name)
        userCharacter?.onNext(char)
    }

    // Method to reset all local data.
    func resetData() {
        LocalData.it.resetData()
        userCharacter = nil
        Logger.it.info("Reset data")
    }
    
    // Method to save the current character.
    private func saveCharacter() {
        guard let character = getChar() else {
            return
        }
        LocalData.it.saveCharacter(character)
    }
    
    // Helper method to get the current character as an object.
    private func getChar() -> UserCharacter? {
        guard let optChar = try? userCharacter?.value() else {
            return nil
        }
        guard let char = optChar else {
            return nil
        }
        
        return char
    }

    // Sets up saving whenever the character is changed.
    private func setupAutosaveCharacter() {
        userCharacter?.subscribe { event in
            guard let player = event.element else {
                return
            }

            LocalData.it.saveCharacter(player)
            Logger.it.info("Saved character")
        }.disposed(by: disposeBag)
    }
}
