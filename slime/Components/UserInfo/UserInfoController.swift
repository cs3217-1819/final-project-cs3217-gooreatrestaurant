//
//  UserInfoController.swift
//  slime
//
//  Created by Gabriel Tan on 30/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import RxSwift

class UserInfoController: Controller {
    let view: UserInfoView
    private let disposeBag = DisposeBag()
    private var progressBarController: ProgressBarController?
    private let character = BehaviorSubject<UserCharacter?>(value: nil)
    
    init(usingXib xibView: XibView) {
        guard let trueView = xibView.contentView as? UserInfoView else {
            Logger.it.error("Nib class is wrong")
            fatalError()
        }
        view = trueView
    }
    
    func set(character: UserCharacter) {
        self.character.onNext(character)
    }
    
    func configure() {
        setupProgressBar()
        setupReactive()
    }
    
    private func setupProgressBar() {
        progressBarController = ProgressBarController(usingXib: view.progressBarView, maxValue: 100)
        progressBarController?.configure()
    }
    
    private func setupReactive() {
        character.subscribe { event in
            guard let optionalPlayer = event.element else {
                return
            }
            guard let player = optionalPlayer else {
                return
            }
            self.refreshView(player: player)
        }.disposed(by: disposeBag)
    }
    
    private func refreshView(player: UserCharacter) {
        view.levelLabel.text = "\(player.level)"
        view.nameLabel.text = player.name
        progressBarController?.setCurrentValue(Double(player.exp))
    }
}
