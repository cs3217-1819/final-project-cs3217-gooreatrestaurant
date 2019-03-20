//
//  RouteTransitionHandler.swift
//  slime
//
//  Created by Gabriel Tan on 18/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import RxSwift

class RouteTransitionHandler {
    private let disposeBag: DisposeBag = DisposeBag()
    private let route: BehaviorSubject<Route>
    var previousRoute: Route?
    var currentRoute: Route {
        guard let value = try? route.value() else {
            fatalError("Route should always have a value")
        }
        return value
    }
    
    init(route: Route) {
        self.route = BehaviorSubject(value: route)
    }
    
    func subscribe(_ callback: @escaping (Route) -> ()) {
        route.distinctUntilChanged().subscribe { event in
            guard let element = event.element else {
                return
            }
            callback(element)
        }.disposed(by: disposeBag)
    }
    
    func onNext(_ route: Route) {
        previousRoute = currentRoute
        self.route.onNext(route)
    }
}
