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

class ButtonController {
    private let disposeBag = DisposeBag()
    let view: UIView
    init(using view: UIView) {
        self.view = view
    }
    
    func onTap(_ callback: @escaping () -> ()) {
        view.rx.gesture(.tap())
            .when(.recognized)
            .subscribe { _ in
                callback()
        }.disposed(by: disposeBag)
    }
}
