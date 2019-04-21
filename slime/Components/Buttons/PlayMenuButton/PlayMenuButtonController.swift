//
//  PlayMenuButtonController.swift
//  slime
//
//  Created by Gabriel Tan on 14/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import RxSwift

class PlayMenuButtonController: Controller {
    var view: UIView {
        return button
    }
    private let disposeBag = DisposeBag()
    private var buttonController: ButtonController
    private weak var button: PlayMenuButton!
    private var title = BehaviorSubject(value: "")
    private var description = BehaviorSubject(value: "")

    init(using view: UIView) {
        button = UIView.initFromNib("PlayMenuButton")
        view.addSubview(button)
        buttonController = ButtonController(using: button)

        setupReactive()
    }

    init(using view: XibView) {
        button = view.getView()
        buttonController = ButtonController(using: button)
    }

    func configure() {
        setupReactive()
    }

    func set(title: String) -> PlayMenuButtonController {
        self.title.onNext(title)
        return self
    }

    func set(description: String) -> PlayMenuButtonController {
        self.description.onNext(description)
        return self
    }

    func set(imageName: String) -> PlayMenuButtonController {
        button.imageView.image = UIImage(named: imageName)
        return self
    }

    func onTap(_ callback: @escaping () -> Void) {
        buttonController.disposableOnTap(callback).disposed(by: disposeBag)
    }

    private func setupReactive() {
        title.asObservable()
            .subscribe { [weak self] event in
                guard let text = event.element else {
                    return
                }
                self?.button.titleLabel.text = text
            }.disposed(by: disposeBag)
        description.asObservable()
            .subscribe { [weak self] event in
                guard let text = event.element else {
                    return
                }
                self?.button.descriptionLabel.text = text
            }.disposed(by: disposeBag)
    }
}
