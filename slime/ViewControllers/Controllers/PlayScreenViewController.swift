//
//  PlayScreenViewController.swift
//  slime
//
//  Created by Gabriel Tan on 14/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class PlayScreenViewController: ViewController<PlayScreenView> {
    required init(with view: UIView) {
        super.init(with: view)
    }
    
    override func configureSubviews() {
        configureButtons()
        configureUpButton(to: .TitleScreen)
    }
    
    private func configureButtons() {
        let singlePlayerButtonController = PlayMenuButtonController(using: view.singlePlayerButton)
            .set(title: "Single Player Mode")
            .set(description: "Play alone to cure your depression!")
        singlePlayerButtonController.onTap {
            self.router.routeTo(.LevelSelect)
        }
        let multiplayerButtonController = PlayMenuButtonController(using: view.multiplayerButton)
            .set(title: "Multiplayer Mode")
            .set(description: "Wreck havoc with your friends!")
        multiplayerButtonController.onTap {
            self.router.routeTo(.MultiplayerScreen)
        }
        let levelEditorButtonController = PlayMenuButtonController(using: view.levelEditorButton)
            .set(title: "Level Editor")
            .set(description: "Edit some levels!")
        levelEditorButtonController.onTap {
            let alert = self.context.createAlert()
                .setTitle("Uh-oh!")
                .setDescription("This feature is coming soon(TM).")
                .addAction(AlertAction(with: "OK"))
            self.context.presentUnimportantAlert(alert)
        }
        
        remember(singlePlayerButtonController)
        remember(multiplayerButtonController)
        remember(levelEditorButtonController)
    }
}
