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
        setupStoryModeView()
        configureUpButton(to: .PlayScreen)
    }

    func setupStoryModeView() {
        let storyModeView = UIView.initFromNib("StoryModeLevelSelectView")
        storyModeController = StoryModeLevelSelectController(with: storyModeView)
        storyModeController?.use(context: context)
        view.childView.addSubview(storyModeView)
        storyModeController?.configureSubviews()
    }
}
