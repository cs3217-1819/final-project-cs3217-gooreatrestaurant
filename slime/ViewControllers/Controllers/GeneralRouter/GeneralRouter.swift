//
//  GeneralRouter.swift
//  slime
//
//  Created by Gabriel Tan on 4/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import Foundation
import UIKit

class GeneralRouter {
    private let routes: [String: RouteManager]
    var previousRoute: String? {
        return transitionHandler.previousRoute
    }
    var currentRoute: String {
        return transitionHandler.currentRoute
    }
    private(set) var currentViewController: ViewControllerProtocol
    private let transitionHandler: GeneralRouteTransitionHandler
    
    init(routes: [String: RouteManager], start: String) {
        self.routes = routes
        transitionHandler = GeneralRouteTransitionHandler(route: start)
        
        guard let startManager = routes[start] else {
            Logger.it.error("Route not found")
            fatalError()
        }
        currentViewController = startManager.createController()
        
        transitionHandler.subscribe { route in
            self.currentViewController = self.getRoute(named: route)
        }
    }
    
    func routeTo(_ route: String) {
        transitionHandler.onNext(route)
    }
    
    private func getRoute(named name: String) -> ViewControllerProtocol {
        guard let manager = routes[name] else {
            Logger.it.error("Route not found")
            fatalError()
        }
        return manager.createController()
    }
}


class RouteManager {
    let nibName: String
    init(nibName: String) {
        self.nibName = nibName
    }
    
    func createController() -> ViewControllerProtocol {
        return UIView.initFromNib(nibName) as! ViewControllerProtocol
    }
}
