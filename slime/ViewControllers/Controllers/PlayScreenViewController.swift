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
        let levelEditorButtonController = PlayMenuButtonController(using: view.levelEditorButton)
        levelEditorButtonController.configure()
        _ = levelEditorButtonController
            .set(title: "Level Editor")
            .set(description: "Edit some levels!")
        levelEditorButtonController.onTap {
            let alert = self.context.modal.createAlert()
                .setTitle("Uh-oh!")
                .setDescription("This feature is coming soon(TM).")
                .addAction(AlertAction(with: "OK"))
            self.context.modal.presentUnimportantAlert(alert)
        }

        remember(singlePlayerButtonController)
        remember(multiplayerButtonController)
        remember(levelEditorButtonController)
    }
}
