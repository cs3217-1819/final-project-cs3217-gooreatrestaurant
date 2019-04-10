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
        case Hats
        case Accessories
    }

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
        
        setupPreview()
        setupReactive()
    }
    
    private func setupPreview() {
        guard let character = context.data.userCharacter else {
            return
        }
        let control = SlimeCharacterController(withXib: view.characterPreviewView)
        control.bindTo(character)
        control.configure()
        remember(control)
    }


    private func setupReactive() {
        route.distinctUntilChanged().subscribe { event in
            guard let route = event.element else {
                return
            }

            var memory = self.currentChildController
            self.currentChildController = self.getControllerFor(route: route)
            self.setupController(self.currentChildController)
            self.innerRouter.setView(self.currentChildController.getView(),
                                     direction: .right,
                                     onComplete: {
                                        memory?.onDisappear()
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
        case .Hats:
            let controller = CustomizationCosmeticViewController(with: getViewFor(route: route))
            let wardrobe = CosmeticConstants.getHats()
            if let char = try? context.data.userCharacter?.value() {
                if let hat = char?.hat {
                    print("using hat: \(hat)")
                    wardrobe.setActiveCosmetic(hat)
                }
            }
            controller.withWardrobe(wardrobe)
            controller.setSaveFunction { cosmetic in
                self.context.data.changeHat(cosmetic.name)
            }
            return controller
        case .Accessories:
            let controller = CustomizationCosmeticViewController(with: getViewFor(route: route))
            let wardrobe = CosmeticConstants.getAccessories()
            if let char = try? context.data.userCharacter?.value() {
                if let accessory = char?.accessory {
                    print("using accessory: \(accessory)")
                    wardrobe.setActiveCosmetic(accessory)
                }
            }
            controller.withWardrobe(wardrobe)
            controller.setSaveFunction { cosmetic in
                self.context.data.changeAccessory(cosmetic.name)
            }
            return controller
        }
    }

    private func getViewFor(route: CustomizationRoute) -> UIView {
        switch(route) {
        case .Main:
            return UIView.initFromNib("CustomizationMainView")
        case .Hats, .Accessories:
            return UIView.initFromNib("CustomizationCosmeticView")
        }
    }

    private func setRoute(_ route: CustomizationRoute) {
        self.route.onNext(route)
    }
}
