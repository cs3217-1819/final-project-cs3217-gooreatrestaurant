//
//  PrimaryButtonController.swift
//  slime
//
//  Created by Gabriel Tan on 13/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import RxSwift

class PrimaryButtonController: Controller {
    var view: UIView {
        return button
    }
    private let disposeBag = DisposeBag()

    private let buttonController: ButtonController
    private let button: PrimaryButton
    private var color = BehaviorSubject(value: PrimaryButtonColor.purple)
    private var label = BehaviorSubject(value: "")

    init(using view: UIView) {
        guard let trueView = view as? PrimaryButton else {
            fatalError("Nib class is wrong")
        }
        button = trueView
        buttonController = ButtonController(using: button)

        setupReactive()
    }

    init(using view: XibView) {
        guard let button = view.contentView as? PrimaryButton else {
            fatalError("Content view is unavailable")
        }
        self.button = button
        buttonController = ButtonController(using: button)
    }

    func configure() {
        setupReactive()
    }

    func set(color: PrimaryButtonColor) -> PrimaryButtonController {
        self.color.onNext(color)
        return self
    }

    func set(label: String) -> PrimaryButtonController {
        self.label.onNext(label)
        return self
    }

    func onTap(_ callback: @escaping () -> Void) {
        buttonController.onTap(callback)
    }

    private func setupReactive() {
        color.asObservable()
            .subscribe { event in
                guard let color = event.element else {
                    return
                }
                self.button.buttonImage.image = color.image
            }
            .disposed(by: disposeBag)
        label.asObservable()
            .subscribe { event in
                guard let text = event.element else {
                    return
                }
                self.button.label.text = text
            }.disposed(by: disposeBag)
    }
}
