//
//  GeneralRouteTransitionHandler.swift
//  slime
//
//  Created by Gabriel Tan on 7/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import RxSwift

class GeneralRouteTransitionHandler {
    private let disposeBag: DisposeBag = DisposeBag()
    private let route: BehaviorSubject<String>
    var previousRoute: String?
    var currentRoute: String {
        guard let value = try? route.value() else {
            fatalError("Route should always have a value")
        }
        return value
    }
    
    init(route: String) {
        self.route = BehaviorSubject(value: route)
    }
    
    func subscribe(_ callback: @escaping (String) -> ()) {
        route.distinctUntilChanged().subscribe { event in
            guard let element = event.element else {
                return
            }
            callback(element)
        }.disposed(by: disposeBag)
    }
    
    func onNext(_ route: String) {
        previousRoute = currentRoute
        self.route.onNext(route)
    }
}
