//
//  AudioController.swift
//  slime
//
//  Created by Developer on 6/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import Foundation
import AVFoundation

class AudioController {
    private(set) var music: AVAudioPlayer!

    func playMusic(_ audioName: String, _ ifLoop: Bool) {
        do {
            music = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath:
                Bundle.main.path(forResource: audioName, ofType: "mp3")!))
            music.numberOfLoops = ifLoop ? -1 : 0
            music.play()
            music.volume = 100
            print("Playing music!")
        } catch {
            print("Error loading Music")
        }
    }
    func stopMusic() {
        music.stop()
    }
}
