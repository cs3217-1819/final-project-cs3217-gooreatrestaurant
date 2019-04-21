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
    private let character: BehaviorSubject<UserCharacter>

    init(usingXib xibView: XibView, boundTo rxChar: BehaviorSubject<UserCharacter>) {
        guard let trueView = xibView.contentView as? UserInfoView else {
            Logger.it.error("Nib class is wrong")
            fatalError()
        }
        character = rxChar
        view = trueView
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
        character.subscribe { [weak self] event in
            guard let player = event.element else {
                return
            }
            self?.refreshView(player: player)
        }.disposed(by: disposeBag)
    }

    private func refreshView(player: UserCharacter) {
        view.levelLabel.text = "\(player.level)"
        view.nameLabel.text = player.name
        progressBarController?.setCurrentValue(Double(player.exp))
    }
}
