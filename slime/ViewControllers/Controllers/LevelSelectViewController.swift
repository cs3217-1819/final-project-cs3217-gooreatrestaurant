//
//  LevelSelectViewController.swift
//  slime
//
//  Created by Gabriel Tan on 15/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class LevelSelectViewController: ViewController<LevelSelectView> {
    private var storyModeController: StoryModeLevelSelectController?
    
    override func configureSubviews() {
        setupButtons()
        setupStoryModeView()
        configureUpButtonAsPrevious()
    }
    
    func setupStoryModeView() {
        view.storyButton.color = "white1"
        let storyModeView = UIView.initFromNib("StoryModeLevelSelectView")
        storyModeController = StoryModeLevelSelectController(with: storyModeView)
        storyModeController?.use(context: context)
        view.childView.addSubview(storyModeView)
        storyModeController?.configureSubviews()
    }
    
    func setupButtons() {
        let storyButtonController = ButtonController(using: view.storyButton)
        storyButtonController.onTap {
            print("To story mode")
        }
        let customButtonController = ButtonController(using: view.customButton)
        customButtonController.onTap {
            let alert = self.context.createAlert()
                .setTitle("Uh-oh!")
                .setDescription("We will implement this soon(TM)")
                .addAction(AlertAction(with: "OK"))
            self.context.presentUnimportantAlert(alert)
        }
        rememberAll([
            storyButtonController,
            customButtonController
        ])
    }
}
