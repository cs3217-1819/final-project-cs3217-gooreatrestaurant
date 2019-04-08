//
//  ItemBoxController.swift
//  slime
//
//  Created by Gabriel Tan on 8/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import RxSwift

class ItemBoxController: Controller {
    private let disposeBag = DisposeBag()
    let view: ItemBoxView
    var active: Bool {
        get {
            return try! activeSubject.value()
        }
        set {
            activeSubject.onNext(newValue)
        }
    }

    private let activeSubject: BehaviorSubject<Bool> = BehaviorSubject(value: false)

    init(withXib xibView: XibView) {
        view = xibView.getView()
    }

    func configure() {
        setupReactive()
        setActiveState()
    }
    
    func setCosmetic(_ cosmetic: Cosmetic) {
        view.itemImageView.image = cosmetic.image
    }

    private func setupReactive() {
        activeSubject.distinctUntilChanged().subscribe { _ in
            self.setActiveState()
        }.disposed(by: disposeBag)
    }

    private func setActiveState() {
        if active {
            view.itemContainerView.background = "pink2"
        } else {
            view.itemContainerView.background = "pink3"
        }
    }
}
