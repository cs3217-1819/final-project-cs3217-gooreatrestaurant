//
//  Context.swift
//  slime
//
//  Created by Gabriel Tan on 18/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import RxSwift

// The Context object houses objects that are commonly used
// amongst controllers.
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

    // Routes to a given route, using the coordinate system.
    func routeTo(_ route: Route) {
        let previousRoute = router.currentRoute
        let previousVC = router.currentViewController
        router.routeTo(route)
        mainController.performSegue(from: previousVC,
                                    to: router.currentViewController,
                                    coordsDiff: router.currentRoute.coordinates - previousRoute.coordinates)
    }
    
    // Performs a fade transition between routes.
    func routeToFade(_ route: Route) {
        let previousVC = router.currentViewController
        router.routeTo(route)
        mainController.performSegue(from: previousVC,
                                    to: router.currentViewController)
    }

    // Returns the view controller after routing.
    // configureSubviews is called before returning.
    func routeToAndPrepareFor<Control: ViewControllerProtocol>(_ route: Route) -> Control {
        routeTo(route)
        return router.currentViewController as! Control
    }
    
    // Returns the view controller after routing, but using the fade transition.
    // configureSubviews is called before returning.
    func routeToAndPrepareForFade<Control: ViewControllerProtocol>(_ route: Route) -> Control {
        routeToFade(route)
        return router.currentViewController as! Control
    }
    
    // Does a preparation callback before performing the routing.
    func routeToFade(_ route: Route, withCallback callback: (ViewControllerProtocol) -> ()) {
        let previousVC = router.currentViewController
        router.routeTo(route)
        callback(router.currentViewController)
        mainController.performSegue(from: previousVC,
                                    to: router.currentViewController)
    }
    
    // Does a preparation callback before performing the routing.
    func routeToAndPrepareFor(_ route: Route, callback: (ViewControllerProtocol) -> ()) {
        let previousRoute = router.currentRoute
        let previousVC = router.currentViewController
        router.routeTo(route)
        callback(router.currentViewController)
        mainController.performSegue(from: previousVC,
                                    to: router.currentViewController,
                                    coordsDiff: router.currentRoute.coordinates - previousRoute.coordinates)
        
    }

    // Performs a segue to the game scene with a specified level.
    func segueToGame(with level: Level) {
        routeToFade(.GameScreen, withCallback: { vc in
            let gameVC = vc as! GameViewController
            gameVC.setLevel(level: level)
            
            guard let character = try! self.data.userCharacter?.value() else {
                return
            }
            gameVC.setSingleplayerUser(player: Player(from: character))
        })
    }
    
    // Performs a segue to the multiplayer screen with a specified room and level.
    func segueToMultiplayerGame(forRoom room: RoomModel, level: Level) {
        routeToFade(.GameScreen) { (controller) in
            guard let vc = controller as? GameViewController else { return }
            vc.isMultiplayer = true
            vc.setLevel(level: level)
            vc.previousRoom = room
        }
    }
}
