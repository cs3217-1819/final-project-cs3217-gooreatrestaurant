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
    private var cosmetic = BehaviorSubject<Cosmetic?>(value: nil)
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
        self.cosmetic.onNext(cosmetic)
        view.itemImageView.image = cosmetic.image
    }

    private func setupReactive() {
        activeSubject.distinctUntilChanged().subscribe { _ in
            self.setActiveState()
        }.disposed(by: disposeBag)
        
        cosmetic.subscribe { event in
            guard let element = event.element else {
                return
            }
            
            self.setUnusedState(element)
        }.disposed(by: disposeBag)
    }

    private func setActiveState() {
        if active {
            view.itemContainerView.background = "pink3"
        } else {
            view.itemContainerView.background = "pink7"
        }
    }
    
    private func setUnusedState(_ cosmetic: Cosmetic?) {
        if cosmetic == nil {
            view.itemImageView.image = ImageProvider.get("cosmetic-none")
        }
    }
}
