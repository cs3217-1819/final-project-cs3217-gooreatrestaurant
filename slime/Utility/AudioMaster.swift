//
//  AudioMaster.swift
//  slime
//
//  Created by Gabriel Tan on 10/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import AVKit

// Singleton class to manage audio effects.
public class AudioMaster {
    public static let instance: AudioMaster = AudioMaster()
    private var bgAudioPlayer: AVAudioPlayer?
    private var bgResource: String?
    private var cache: [String: AVAudioPlayer] = [:]
    private var aliasDict: [String: String] = [:]
    
    private init() {
        // Until these sounds are implemented, set alias here
        setAlias(alias: "order-missed", for: "bad-order")
    }
    
    // Setting alias allows us to call alias instead of name
    public func setAlias(alias: String, for name: String) {
        aliasDict[alias] = name
    }
    
    // Plays background music. Only one BGM can be playing at any given time.
    public func playBGM(name: String) {
        let trueName = getTrueName(name: name)
        if let bgName = bgResource, bgName == trueName {
            // BG is already playing
            return
        }
        guard let sound = Bundle.main.path(forResource: trueName, ofType: "mp3") else {
            return
        }
        do {
            bgAudioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound))
            bgAudioPlayer?.numberOfLoops = -1 // infinite loop
            bgAudioPlayer?.play()
            bgResource = trueName
        } catch {
            Logger.it.error("\(error)")
            return
        }
    }
    
    // Stops the BGM.
    public func stopBGM() {
        bgAudioPlayer?.stop()
    }
    
    // Plays a separate SFX, so multiple same SFX players can be played simultaneously.
    public func playSeparateSFX(name: String) -> AVAudioPlayer? {
        guard let sound = Bundle.main.path(forResource: name, ofType: "mp3") else {
            return nil
        }
        do {
            let player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound))
            player.play()
            return player
        } catch {
            Logger.it.error("\(error)")
            return nil
        }
    }
    
    // Plays a given SFX. For this SFX, only 1 instance can be playing at the same time
    // by using this method.
    public func playSFX(name: String) {
        let trueName = getTrueName(name: name)
        if let player = cache[trueName] {
            if player.isPlaying {
                player.pause()
            }
            player.currentTime = 0
            player.play()
            return
        }
        guard let sound = Bundle.main.path(forResource: trueName, ofType: "mp3") else {
            return
        }
        do {
            let player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound))
            player.play()
            cache[trueName] = player
        } catch {
            Logger.it.error("\(error)")
            return
        }
    }
    
    // Utility function to get the true sound path for a certain name.
    private func getTrueName(name: String) -> String {
        if let trueName = aliasDict[name] {
            return trueName
        }
        return name
    }
}
