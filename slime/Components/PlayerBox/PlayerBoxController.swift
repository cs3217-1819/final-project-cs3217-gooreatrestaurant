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
    
    private func setName(_ name: String) {
        view.nameLabel.text = name
    }
    
    private func setLevel(_ level: Int) {
        view.levelLabel.text = "Level \(level)"
    }
    
    private func setNotConnected() {
        view.avatarImageView.image = ImageProvider.get("mc-slime-single")
        setName("Disconnected")
        view.levelLabel.text = ""
    }
    
    private func setupReactive() {
        player.asObservable()
            .subscribe { event in
                guard let player = event.element else {
                    return
                }
                guard let truePlayer = player else {
                    self.setNotConnected()
                    return
                }
                self.setName(truePlayer.name)
                self.setLevel(truePlayer.level)
            }.disposed(by: disposeBag)
    }
}
