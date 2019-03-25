//
//  PlayMenuButtonController.swift
//  slime
//
//  Created by Gabriel Tan on 14/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import RxSwift

class PlayMenuButtonController {
    private let disposeBag = DisposeBag()
    
    private let buttonController: ButtonController
    private let button: PlayMenuButton
    private var title = BehaviorSubject(value: "")
    private var description = BehaviorSubject(value: "")
    
    init(using view: UIView) {
        button = UIView.initFromNib("PlayMenuButton")
        view.addSubview(button)
        buttonController = ButtonController(using: button)
        
        setupReactive()
    }
    
    init(using view: XibView) {
        guard let button = view.contentView as? PlayMenuButton else {
            fatalError("Content view is unavailable")
        }
        self.button = button
        buttonController = ButtonController(using: button)
        
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
    
    func onTap(_ callback: @escaping () -> ()) {
        buttonController.onTap(callback)
    }
    
    private func setupReactive() {
        title.asObservable()
            .subscribe { event in
                guard let text = event.element else {
                    return
                }
                self.button.titleLabel.text = text
            }.disposed(by: disposeBag)
        description.asObservable()
            .subscribe { event in
                guard let text = event.element else {
                    return
                }
                self.button.descriptionLabel.text = text
            }.disposed(by: disposeBag)
    }
}
