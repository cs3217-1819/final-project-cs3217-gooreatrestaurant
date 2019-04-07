//
//  GeneralRouterContext.swift
//  slime
//
//  Created by Gabriel Tan on 7/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class GeneralRouterContext {
    enum Direction {
        case up
        case down
        case left
        case right
    }
    let router: GeneralRouter
    var segueDelegate: SegueDelegate?
    
    init(routes: [String: RouteManager], start: String) {
        router = GeneralRouter(routes: routes, start: start)
    }
    
    func routeTo(_ route: String, direction: Direction) {
        let previousVC = router.currentViewController
        router.routeTo(route)
        let nextVC = router.currentViewController
        segueDelegate?.performSegue(fromVC: previousVC,
                                    toVC: nextVC,
                                    coordsDiff: getCoordsDiff(direction: direction))
    }
    
    func routeToAndPrepareFor<Control: ViewControllerProtocol>(_ route: String, direction: Direction) ->
        Control {
        let previousVC = router.currentViewController
        router.routeTo(route)
        let nextVC = router.currentViewController
        segueDelegate?.performSegue(fromVC: previousVC,
                                    toVC: nextVC,
                                    coordsDiff: getCoordsDiff(direction: direction))
        return nextVC as! Control
    }
    
    private func getCoordsDiff(direction: Direction) -> CGPoint {
        guard let delegate = segueDelegate else {
            return CGPoint(x: 0, y: 0)
        }
        let dimensions = delegate.getViewDimensions()
        let width = dimensions.width
        let height = dimensions.height
        switch(direction) {
        case .up:
            return CGPoint(x: 0, y: height)
        case .down:
            return CGPoint(x: 0, y: -height)
        case .left:
            return CGPoint(x: -width, y: 0)
        case .right:
            return CGPoint(x: width, y: 0)
        }
    }
    
    
}
