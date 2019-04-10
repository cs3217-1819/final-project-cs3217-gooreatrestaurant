//
//  SlimeNumberInputController.swift
//  slime
//
//  Created by Gabriel Tan on 27/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import RxSwift

class SlimeNumberInputController: Controller {
    enum Color {
        case yellow
        case blue
        case purple
        case green
    }

    let view: SlimeNumberInputView
    private let text = BehaviorSubject(value: "")
    private let color = BehaviorSubject<Color>(value: .yellow)
    private let buttonController: ButtonController
    private let disposeBag = DisposeBag()

    init(with view: UIView?) {
        guard let trueView = view as? SlimeNumberInputView else {
            fatalError("Nib class is wrong")
        }
        self.view = trueView

        buttonController = ButtonController(using: self.view)
    }

    convenience init(withXib xibView: XibView) {
        self.init(with: xibView.contentView)
    }

    func configure() {
        setupReactive()
    }

    func set(number: Int) -> SlimeNumberInputController {
        text.onNext("\(number)")
        return self
    }

    func set(text: String) -> SlimeNumberInputController {
        self.text.onNext(text)
        return self
    }

    func set(color: Color) -> SlimeNumberInputController {
        self.color.onNext(color)
        return self
    }

    func onTap(_ callback: @escaping () -> Void) -> SlimeNumberInputController {
        buttonController.onTap(callback)
        return self
    }

    private func setupReactive() {
        text.distinctUntilChanged().subscribe { event in
            guard let element = event.element else {
                return
            }
            self.view.numberLabel.text = element
            self.view.numberLabel.strokeWidth = self.view.numberLabel.strokeWidth
        }.disposed(by: disposeBag)

        color.distinctUntilChanged().subscribe { event in
            guard let element = event.element else {
                return
            }
            switch(element) {
            case .yellow:
                self.view.slimeImageView.image = ImageProvider.get("numberpad-button-yellow")
            case .blue:
                self.view.slimeImageView.image = ImageProvider.get("numberpad-button-blue")
            case .purple:
                self.view.slimeImageView.image = ImageProvider.get("numberpad-button-purple")
            case .green:
                self.view.slimeImageView.image = ImageProvider.get("numberpad-button-green")
            }
        }.disposed(by: disposeBag)
    }
}
