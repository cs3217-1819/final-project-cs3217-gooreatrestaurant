//
//  PlayerBoxController.swift
//  slime
//
//  Created by Gabriel Tan on 19/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import RxSwift

class PlayerBoxController {
    private let disposeBag = DisposeBag()
    private let view: PlayerBox
    private var player = BehaviorSubject(value: Player(name: "TestPlayer", level: 1))
    
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
        
        setupReactive()
    }
    
    func setPlayer(_ player: Player) {
        self.player.onNext(player)
    }
    
    private func setName(_ name: String) {
        view.nameLabel.text = name
    }
    
    private func setLevel(_ level: Int) {
        view.levelLabel.text = "Level \(level)"
    }
    
    private func setupReactive() {
        player.asObservable()
            .subscribe { event in
                guard let player = event.element else {
                    return
                }
                self.setName(player.name)
                self.setLevel(player.level)
            }.disposed(by: disposeBag)
    }
}
