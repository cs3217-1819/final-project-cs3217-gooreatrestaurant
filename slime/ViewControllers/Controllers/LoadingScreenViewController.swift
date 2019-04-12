//
//  LoadingScreenViewController.swift
//  slime
//
//  Created by Gabriel Tan on 20/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//
import Foundation

class LoadingScreenViewController: ViewController<LoadingScreenView> {
    override func configureSubviews() {
        configureTutorial()
    }
    
    private func configureTutorial() {
        let controller = TutorialScreenController(withXib: view.tutorialScreenView)
        controller.use(tutorialSteps: TutorialConstants.cutApple)
        controller.onDone {
            self.context.segueToGame()
        }
        controller.configure()
        
        remember(controller)
    }
}
