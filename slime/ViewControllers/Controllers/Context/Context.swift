//
//  Context.swift
//  slime
//
//  Created by Gabriel Tan on 18/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import RxSwift

class Context {
    let router = Router(with: .TitleScreen)
    let db: GameDatabase = GameDB()
    private var baseView: UIView {
        return mainController.view
    }
    private let mainController: MainController
    let modal: ContextModalHandler
    let data = ContextDataHandler()
    
    init(using viewController: MainController) {
        self.mainController = viewController
        modal = ContextModalHandler(baseView: viewController.view)
        data.loadUserData()
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
    
    func segueToMultiplayerGame() {
        mainController.performSegue(withIdentifier: "toMultiplayerGame", sender: nil)
    }
}


