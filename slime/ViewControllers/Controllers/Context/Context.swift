//
//  Context.swift
//  slime
//
//  Created by Gabriel Tan on 18/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class Context {
    let router = Router(with: .TitleScreen)
    private var baseView: UIView {
        return mainController.view
    }
    private let mainController: MainController
    private let modal = ModalController()
    
    init(using viewController: MainController) {
        self.mainController = viewController
    }
    
    func showModal(view: UIView) {
        modal.setContent(view)
        modal.configure()
        modal.open(with: baseView)
    }
    
    func closeModal() {
        modal.close()
    }
    
    func createAlert() -> AlertController {
        return AlertController(using: modal)
    }
    
    func presentAlert(_ alert: AlertController) {
        alert.configure()
        modal.configure()
        modal.open(with: baseView, closeOnOutsideTap: false)
    }
    
    func presentUnimportantAlert(_ alert: AlertController) {
        alert.configure()
        modal.configure()
        modal.open(with: baseView, closeOnOutsideTap: true)
    }
    
    func routeTo(_ route: Route) {
        let previousRoute = router.currentRoute
        let previousVC = router.currentViewController
        router.routeTo(route)
        mainController.performSegue(from: previousVC,
                                    to: router.currentViewController,
                                    coordsDiff: router.currentRoute.coordinates - previousRoute.coordinates)
    }
    
    func routeToAndPrepareFor<Control: ViewControllerProtocol>(_ route: Route) -> Control {
        routeTo(route)
        return router.currentViewController as! Control
    }
    
    func segueToGame() {
        mainController.performSegue(withIdentifier: "toGame", sender: nil)
    }
}
