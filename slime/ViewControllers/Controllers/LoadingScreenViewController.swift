//
//  LoadingScreenViewController.swift
//  slime
//
//  Created by Gabriel Tan on 20/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//
import Foundation

class LoadingScreenViewController: ViewController<LoadingScreenView> {
    private var levelToLoad: Level?
    
    // set filename of level to load
    func setLevelToLoad(_ levelToLoad: Level) {
        self.levelToLoad = levelToLoad
    }
    
    override func configureSubviews() {
        configureTutorial()
    }
    
    private func configureTutorial() {
        let controller = TutorialScreenController(withXib: view.tutorialScreenView)
        controller.use(tutorialSteps: TutorialConstants.cutApple)
        controller.onDone {
            guard let level = self.levelToLoad else {
                return
            }
            self.context.segueToGame(with: level)
        }
        controller.configure()
        
        remember(controller)
    }
}
