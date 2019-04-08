//
//  CustomizationCosmeticViewController.swift
//  slime
//
//  Created by Gabriel Tan on 8/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import RxSwift

class CustomizationCosmeticViewController: ViewController<CustomizationCosmeticView>,
    CustomizationController {
    private let disposeBag = DisposeBag()
    private lazy var itemBoxes = [
        view.itemBoxOne,
        view.itemBoxTwo,
        view.itemBoxThr,
        view.itemBoxFour,
        view.itemBoxFive,
        view.itemBoxSix,
        view.itemBoxSeven,
        view.itemBoxEight,
        view.itemBoxNine
    ]
    
    private var saveFunction: ((Cosmetic) -> ())?
    private var wardrobe: Wardrobe!
    private var itemBoxControllers: [ItemBoxController] = []
    private var routeSubject: BehaviorSubject<CharacterCustomizationViewController.CustomizationRoute>!

    func use(routeSubject: BehaviorSubject<CharacterCustomizationViewController.CustomizationRoute>) {
        self.routeSubject = routeSubject
    }
    
    func setSaveFunction(_ callback: @escaping (Cosmetic) -> ()) {
        saveFunction = callback
    }
    
    func withWardrobe(_ wardrobe: Wardrobe) {
        self.wardrobe = wardrobe
    }
    
    override func configureSubviews() {
        setupWardrobe()
        setupButtons()
    }
    
    private func setupWardrobe() {
        for itemBox in itemBoxes {
            guard let box = itemBox else {
                return
            }
            let control = ItemBoxController(withXib: box)
            control.configure()
            itemBoxControllers.append(control)
        }
        
        wardrobe.bindTo(itemBoxControllers)
        wardrobe.activeIndex.subscribe { _ in
            self.saveItem()
        }.disposed(by: disposeBag)
    }
    
    private func setupButtons() {
        let controller = ButtonController(using: view.backButton)
        controller.onTap {
            self.routeSubject.onNext(.Main)
        }
        
        remember(controller)
    }
    
    private func saveItem() {
        guard let selectedItem = wardrobe.selected else {
            return
        }
        
        saveFunction?(selectedItem)
    }

}
