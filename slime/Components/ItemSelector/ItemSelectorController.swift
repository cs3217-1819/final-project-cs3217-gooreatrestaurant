//
//  ItemSelectorController.swift
//  slime
//
//  Created by Gabriel Tan on 1/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import RxSwift

class ItemSelectorController<Item: Equatable>: Controller {
    let view: ItemSelectorView
    var value: Item? {
        get {
            guard let index = try? currentIndex.value() else {
                return nil
            }
            if index < 0 || index >= items.count {
                return nil
            }
            return items[index].0
        }
        set {
            guard let nextValue = newValue else {
                return
            }
            for (i, item) in items.enumerated() {
                if item.0 == nextValue {
                    currentIndex.onNext(i)
                }
            }
        }
    }
    private var currentIndex = BehaviorSubject(value: 0)
    private var items: [(Item, UIImage)] = []
    private let disposeBag = DisposeBag()
    
    init(withXib xibView: XibView) {
        view = xibView.getView()
    }
    
    func configure() {
        setupListeners()
        setupReactive()
    }
    
    func set(items: [(Item, UIImage)]) {
        self.items = items
    }
    
    private func toNextItem() {
        guard let index = try? currentIndex.value() else {
            return
        }
        let count = items.count
        let nextIndex = (index + 1) % count
        currentIndex.onNext(nextIndex)
    }
    
    private func toPreviousItem() {
        guard let index = try? currentIndex.value() else {
            return
        }
        var nextIndex = index - 1
        if nextIndex < 0 {
            let count = items.count
            nextIndex += count
        }
        
        currentIndex.onNext(nextIndex)
    }
    
    private func setupListeners() {
        view.leftArrow.rx.gesture(.tap())
            .when(.recognized)
            .subscribe { _ in
                self.toPreviousItem()
            }.disposed(by: disposeBag)
        view.rightArrow.rx.gesture(.tap())
            .when(.recognized)
            .subscribe { _ in
                self.toNextItem()
            }.disposed(by: disposeBag)
    }
    
    private func setupReactive() {
        currentIndex.subscribe { event in
            guard let index = event.element else {
                return
            }
            self.view.itemImageView.image = self.items[index].1
        }.disposed(by: disposeBag)
    }
}
