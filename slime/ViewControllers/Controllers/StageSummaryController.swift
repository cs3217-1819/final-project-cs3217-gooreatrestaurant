//
//  StageSummaryController.swift
//  slime
//
//  Created by Gabriel Tan on 13/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import RxSwift

class StageSummaryController: ViewController<StageSummaryView> {
    private let disposeBag = DisposeBag()
    var levelID: String = ""
    var expGained: Int = 0
    var stageScore: Int = 0
    var isMultiplayer: Bool = false
    var progressBarControl: ProgressBarController?
    
    override func configureSubviews() {
        setupReactive()
        setupButton()
        setLabels()
        gainExp()
        saveBestScore()
    }
    
    func set(levelID: String, exp: Int, score: Int, isMultiplayer: Bool) {
        self.levelID = levelID
        expGained = exp
        stageScore = score
        self.isMultiplayer = isMultiplayer
    }
    
    private func gainExp() {
        context.data.gainCharacterExp(expGained)
    }
    
    private func setLabels() {
        view.expLabel.text = "\(expGained)"
        view.scoreLabel.text = "\(stageScore)"
    }
    
    private func saveBestScore() {
        LocalData.it.saveBestScore(levelID: levelID, score: stageScore)
    }
    
    private func setupReactive() {
        guard let observableCharacter = context.data.userCharacter else {
            return
        }
        let characterController = SlimeCharacterController(withXib: view.characterView)
        characterController.bindTo(observableCharacter)
        characterController.configure()
        observableCharacter.subscribe { event in
            guard let character = event.element else {
                return
            }
            self.setCharacterDetails(character)
        }.disposed(by: disposeBag)
        
        remember(characterController)
    }
    
    private func setCharacterDetails(_ character: UserCharacter) {
        view.nameLabel.text = character.name
        view.levelLabel.text = "\(character.level)"
        if let existingController = progressBarControl {
            existingController.setCurrentValue(Double(character.exp))
            return
        }
        progressBarControl = ProgressBarController(usingXib: view.progressBarView, maxValue: 100)
        progressBarControl?.setColor(ColorStyles.getColor("pink1")!)
        progressBarControl?.setCurrentValue(Double(character.exp))
        progressBarControl?.configure()
    }
    
    private func setupButton() {
        let control = PrimaryButtonController(usingXib: view.okButton)
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
