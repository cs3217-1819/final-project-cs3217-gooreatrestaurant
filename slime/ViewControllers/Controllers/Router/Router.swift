//
//  Router.swift
//  slime
//
//  Created by Gabriel Tan on 15/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

enum Route {
    case TitleScreen
    case PlayScreen
    case LevelSelect
    case CreditsScreen
    case SettingsScreen
    case MultiplayerScreen
    case MultiplayerLobby
    case LoadingScreen
    
    var coordinates: CGPoint {
        switch(self) {
        case .TitleScreen:
            return CGPoint(x: 0, y: 0)
        case .PlayScreen:
            return CGPoint(x: 0, y: 1)
        case .LevelSelect:
            return CGPoint(x: 0, y: 2)
        case .CreditsScreen:
            return CGPoint(x: -1, y: 0)
        case .SettingsScreen:
            return CGPoint(x: 1, y: 0)
        case .MultiplayerScreen:
            return CGPoint(x: -1, y: 1)
        case .MultiplayerLobby:
            return CGPoint(x: -1, y: 2)
        case .LoadingScreen:
            return CGPoint(x: 0, y: 50)
        }
    }
}

class Router {
    var previousRoute: Route? {
        return transitionHandler.previousRoute
    }
    var currentRoute: Route {
        return transitionHandler.currentRoute
    }
    let transitionHandler: RouteTransitionHandler
    private var currentVC: ViewControllerProtocol
    
    init(with route: Route) {
        transitionHandler = RouteTransitionHandler(route: route)
        // TODO: change this
        currentVC = TitleScreenViewController(with: UIView.initFromNib("TitleScreenView"))
        
        transitionHandler.subscribe { route in
            self.currentVC = self.getControllerFor(route: route)
        }
    }
    
    func routeTo(_ route: Route)  {
        transitionHandler.onNext(route)
    }
    
    func routeToAndPrepareFor(_ route: Route) -> ViewControllerProtocol {
        routeTo(route)
        return currentVC
    }
    
    func getCurrentViewController() -> ViewControllerProtocol {
        return currentVC
    }
    
    func getControllerFor(route: Route) -> ViewControllerProtocol {
        switch(route) {
        case .TitleScreen:
            return TitleScreenViewController(with: UIView.initFromNib("TitleScreenView"))
        case .PlayScreen:
            return PlayScreenViewController(with: UIView.initFromNib("PlayScreenView"))
        case .LevelSelect:
            return LevelSelectViewController(with: UIView.initFromNib("LevelSelectView"))
        case .CreditsScreen:
            return CreditsSceneViewController(with: UIView.initFromNib("CreditsScreenView"))
        case .SettingsScreen:
            return SettingsScreenViewController(with: UIView.initFromNib("SettingsScreenView"))
        case .MultiplayerScreen:
            return MultiplayerScreenViewController(with: UIView.initFromNib("MultiplayerScreenView"))
        case .MultiplayerLobby:
            return MultiplayerLobbyViewController(with: UIView.initFromNib("MultiplayerLobbyView"))
        case .LoadingScreen:
            return LoadingScreenViewController(with: UIView.initFromNib("LoadingScreenView"))
        }
    }
}
