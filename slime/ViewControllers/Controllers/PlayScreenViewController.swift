//
//  PlayScreenViewController.swift
//  slime
//
//  Created by Gabriel Tan on 14/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class PlayScreenViewController: ViewController<PlayScreenView> {
    private var jokesController: JokesSlimesController?
    required init(with view: UIView) {
        super.init(with: view)
    }

    override func configureSubviews() {
        configureButtons()
        configureJokes()
        configureUpButton(to: .TitleScreen)
    }
    
    private func configureJokes() {
        let controller = JokesSlimesController(withXib: view.jokesSlimeView)
        controller.useJokeSet(jokes: JokeConstants.setOne)
        controller.configure()
        
        jokesController = controller
    }

    private func configureButtons() {
        let singlePlayerButtonController = PlayMenuButtonController(using: view.singlePlayerButton)
        singlePlayerButtonController.configure()
        _ = singlePlayerButtonController
            .set(title: "Single Player Mode")
            .set(description: "Play alone to cure your depression!")
        singlePlayerButtonController.onTap {
            self.context.routeTo(.LevelSelect)
        }
        let multiplayerButtonController = PlayMenuButtonController(using: view.multiplayerButton)
        multiplayerButtonController.configure()
        _ = multiplayerButtonController
            .set(title: "Multiplayer Mode")
            .set(description: "Wreck havoc with your friends!")
            .set(imageName: "slime-multiplayer")
        multiplayerButtonController.onTap {
            self.context.routeTo(.MultiplayerScreen)
        }

        remember(singlePlayerButtonController)
        remember(multiplayerButtonController)
    }
    
    override func onDisappear() {
        super.onDisappear()
        jokesController?.invalidateTimers()
        jokesController = nil
    }
}
