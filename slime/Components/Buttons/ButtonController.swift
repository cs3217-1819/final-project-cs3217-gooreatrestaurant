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
    var view: UIView {
        return _view
    }
    weak var _view: UIView!
    
    init(using view: UIView) {
        _view = view
    }

    func configure() {

    }

    func onTap(_ callback: @escaping () -> Void) {
        disposableOnTap(callback).disposed(by: disposeBag)
    }
    
    func disposableOnTap(_ callback: @escaping () -> Void) -> Disposable {
        return view.rx.gesture(.tap())
            .when(.recognized)
            .subscribe { [weak self] _ in
                guard let this = self else {
                    return
                }
                AudioMaster.instance.playSFX(name: this.sound)
                callback()
        }
    }
    
    func cleanup() {
        
    }
}
