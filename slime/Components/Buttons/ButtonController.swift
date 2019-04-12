//
//  ButtonController.swift
//  slime
//
//  Created by Gabriel Tan on 13/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

class ButtonController: Controller {
    private let disposeBag = DisposeBag()
    var sound: String = "selection"
    
    let view: UIView
    init(using view: UIView) {
        self.view = view
    }

    func configure() {

    }

    func onTap(_ callback: @escaping () -> Void) {
        view.rx.gesture(.tap())
            .when(.recognized)
            .subscribe { _ in
                AudioMaster.instance.playSFX(name: self.sound)
                callback()
        }.disposed(by: disposeBag)
    }
}
