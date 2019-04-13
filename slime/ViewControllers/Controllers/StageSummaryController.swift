//
//  StageSummaryController.swift
//  slime
//
//  Created by Gabriel Tan on 13/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import Foundation

class StageSummaryController: ViewController<StageSummaryView> {
    var expGained: Int = 0
    var stageScore: Int = 0
    var isMultiplayer: Bool = false
    
    override func configureSubviews() {
        setupReactive()
        setupButton()
        setLabels()
        gainExp()
    }
    
    private func gainExp() {
        context.data.gainCharacterExp(expGained)
    }
    
    private func setLabels() {
        view.expLabel.text = "\(expGained)"
        view.scoreLabel.text = "\(stageScore)"
    }
    
    private func setupReactive() {
        guard let observableCharacter = context.data.userCharacter else {
            return
        }
        let characterController = SlimeCharacterController(withXib: view.characterView)
        characterController.bindTo(observableCharacter)
        characterController.configure()
        
        remember(characterController)
    }
    
    private func setupButton() {
        let control = PrimaryButtonController(using: view.okButton)
            .set(label: "OK")
            .set(color: .green)
        control.onTap {
            if self.isMultiplayer {
                self.context.routeTo(.MultiplayerScreen)
            } else {
                self.context.routeTo(.LevelSelect)
            }
        }
        control.configure()
        
        remember(control)
    }
}
