//
//  CharacterCustomizationViewController.swift
//  slime
//
//  Created by Gabriel Tan on 7/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import RxSwift

protocol CustomizationController {
    func use(routeSubject: BehaviorSubject<CharacterCustomizationViewController.CustomizationRoute>)
}

class CharacterCustomizationViewController: ViewController<CharacterCustomizationView> {
    typealias HybridController = ViewControllerProtocol & CustomizationController
    private let disposeBag = DisposeBag()
    enum CustomizationRoute {
        case Main
    }
    
    private var itemSelectController: ItemSelectorController<SlimeColor>?
    private var innerRouter: RouterController!
    private var currentChildController: HybridController!
    private let route: BehaviorSubject<CustomizationRoute> = BehaviorSubject(value: .Main)
    
    override func configureSubviews() {
        configureUpButtonAsPrevious()
        currentChildController = getControllerFor(route: .Main)
        setupController(currentChildController)
        innerRouter = RouterController(with: view.routerPanel,
                                       childView: currentChildController.getView())
        innerRouter.configure()
        setupSelector()
        setupReactive()
    }
    
    override func onDisappear() {
        super.onDisappear()
        guard let newColor = itemSelectController?.value else {
            return
        }
        context.data.changeCharacterColor(newColor)
    }
    
    private func setupSelector() {
        let control = ItemSelectorController<SlimeColor>(withXib: view.characterPreviewView)
        let items: [(SlimeColor, UIImage)] = SlimeColor.allCases
            .map { color in
                guard let image = color.getImage() else {
                    fatalError("Image not found for slime color")
                }
                return (color, image)
        }
        control.set(items: items)
        control.configure()
        context.data.userCharacter?.subscribe { event in
            guard let player = event.element else {
                return
            }
            
            control.value = player.color
        }.disposed(by: disposeBag)
        itemSelectController = control
    }
    
    private func setupReactive() {
        route/*.distinctUntilChanged()*/.subscribe { event in
            guard let route = event.element else {
                return
            }
            
            var memory = self.currentChildController
            self.currentChildController = self.getControllerFor(route: route)
            self.setupController(self.currentChildController)
            self.innerRouter.setView(self.currentChildController.getView(),
                                     direction: .right,
                                     onComplete: {
                                        memory = nil
                                     })
        }.disposed(by: disposeBag)
    }
    
    private func setupController(_ control: HybridController) {
        control.use(context: context)
        control.use(routeSubject: route)
        control.configureSubviews()
    }
    
    private func getControllerFor(route: CustomizationRoute) -> HybridController {
        switch(route) {
        case .Main:
            return CustomizationMainViewController(with: getViewFor(route: route))
        }
    }
    
    private func getViewFor(route: CustomizationRoute) -> UIView {
        switch(route) {
        case .Main:
            return UIView.initFromNib("CustomizationMainView")
        }
    }
    
    private func setRoute(_ route: CustomizationRoute) {
        self.route.onNext(route)
    }
}
