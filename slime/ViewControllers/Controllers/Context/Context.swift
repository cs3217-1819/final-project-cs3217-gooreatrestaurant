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
    
    func routeToFade(_ route: Route) {
        let previousVC = router.currentViewController
        router.routeTo(route)
        mainController.performSegue(from: previousVC,
                                    to: router.currentViewController)
    }

    func routeToAndPrepareFor<Control: ViewControllerProtocol>(_ route: Route) -> Control {
        routeTo(route)
        return router.currentViewController as! Control
    }
    
    func routeToAndPrepareForFade<Control: ViewControllerProtocol>(_ route: Route) -> Control {
        routeToFade(route)
        return router.currentViewController as! Control
    }
    
    func routeToFade(_ route: Route, withCallback callback: (ViewControllerProtocol) -> ()) {
        let previousRoute = router.currentRoute
        let previousVC = router.currentViewController
        router.routeTo(route)
        callback(router.currentViewController)
        mainController.performSegue(from: previousVC,
                                    to: router.currentViewController)
    }
    
    func routeToAndPrepareFor(_ route: Route, callback: (ViewControllerProtocol) -> ()) {
        let previousRoute = router.currentRoute
        let previousVC = router.currentViewController
        router.routeTo(route)
        callback(router.currentViewController)
        mainController.performSegue(from: previousVC,
                                    to: router.currentViewController,
                                    coordsDiff: router.currentRoute.coordinates - previousRoute.coordinates)
        
    }

    func segueToGame(with levelName: String) {
        routeToFade(.GameScreen, withCallback: { vc in
            let gameVC = vc as! GameViewController
            gameVC.setLevel(name: levelName)
        })
    }
    
    func segueToMultiplayerGame(forRoom room: RoomModel, level: String) {
        routeToFade(.GameScreen) { (controller) in
            guard let vc = controller as? GameViewController else { return }
            vc.isMultiplayer = true
            vc.setLevel(name: level)
            vc.previousRoom = room
        }
//        routeToAndPrepareFor(.GameScreen) { (controller) in
//            guard let vc = controller as? GameViewController else { return }
//            vc.isMultiplayer = true
//            vc.previousRoom = room
//        }
    }
}
