//
//  AudioMaster.swift
//  slime
//
//  Created by Gabriel Tan on 10/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import AVKit

public class AudioMaster {
    public static let instance: AudioMaster = AudioMaster()
    private var bgAudioPlayer: AVAudioPlayer?
    private var bgResource: String?
    private var cache: [String: AVAudioPlayer] = [:]
    
    private init() {
    }
    
    public func playBGM(name: String) {
        if let bgName = bgResource, bgName == name {
            // BG is already playing
            return
        }
        guard let sound = Bundle.main.path(forResource: name, ofType: "mp3") else {
            return
        }
        do {
            bgAudioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound))
            bgAudioPlayer?.numberOfLoops = -1 // infinite loop
            bgAudioPlayer?.play()
            bgResource = name
        } catch {
            Logger.it.error("\(error)")
            return
        }
    }
    
    public func stopBGM() {
        bgAudioPlayer?.stop()
    }
    
    public func playSFX(name: String) {
        if let player = cache[name] {
            if player.isPlaying {
                player.pause()
            }
            player.currentTime = 0
            player.play()
            return
        }
        guard let sound = Bundle.main.path(forResource: name, ofType: "mp3") else {
            return
        }
        do {
            let player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound))
            player.volume = 60.0
            player.play()
            cache[name] = player
        } catch {
            Logger.it.error("\(error)")
            return
        }
    }
}
