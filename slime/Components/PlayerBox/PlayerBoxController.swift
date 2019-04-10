//
//  PlayerBoxController.swift
//  slime
//
//  Created by Gabriel Tan on 19/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import RxSwift

class PlayerBoxController: Controller {
    let view: PlayerBox
    private let disposeBag = DisposeBag()
    private var player = BehaviorSubject<Player?>(value: nil)

    init(using view: UIView) {
        guard let trueView = view as? PlayerBox else {
            fatalError("Nib class is wrong")
        }
        self.view = trueView

        setupReactive()
        setupCharacterView()
    }

    init(using view: XibView) {
        guard let trueView = view.contentView as? PlayerBox else {
            fatalError("Content view is unavailable")
        }
        self.view = trueView
    }

    func configure() {
        setupReactive()
    }

    func setPlayer(_ player: Player) {
        self.player.onNext(player)
    }

    func removePlayer() {
        self.player.onNext(nil)
    }

    private func setConnected() {
        view.characterView.alpha = 1
        view.backgroundColor = ColorStyles.getColor("pink6")
    }

    private func setName(_ name: String) {
        view.nameLabel.text = name
    }

    private func setLevel(_ level: Int) {
        view.levelLabel.text = "Level \(level)"
    }

    private func setHost(_ isHost: Bool) {
        // TODO: put host
        if isHost {
            view.hostView.alpha = 1
        } else {
            view.hostView.alpha = 0
        }
    }

    private func setNotConnected() {
        view.backgroundColor = ColorStyles.getColor("white6")
        view.characterView.alpha = 0
        setHost(false)
        setName("Disconnected")
        view.levelLabel.text = ""
    }
    
    private func setupCharacterView() {
        let characterStream = player.flatMap { player -> Observable<UserCharacter> in
            guard let character = player else {
                return Observable.empty()
            }
            let userCharacter = UserCharacter(from: character)
            return Observable.just(userCharacter)
        }
        let characterController = SlimeCharacterController(withXib: view.characterView)
        characterController.bindTo(characterStream)
    }

    private func setupReactive() {
        player.asObservable()
            .subscribe { event in
                guard let optionalPlayer = event.element else {
                    return
                }
                guard let player = optionalPlayer else {
                    self.setNotConnected()
                    return
                }
                self.setConnected()
                self.setName(player.name)
                self.setLevel(player.level)
                self.setHost(player.isHost)
            }.disposed(by: disposeBag)
        
        
    }
}
