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
    case CharacterCreationScreen
    case CharacterCustomizationScreen
    case PlayScreen
    case LevelSelect
    case CreditsScreen
    case SettingsScreen
    case MultiplayerScreen
    case MultiplayerJoinRoomScreen
    case MultiplayerLobby
    case LoadingScreen
    
    var coordinates: CGPoint {
        switch(self) {
        case .TitleScreen:
            return CGPoint(x: 0, y: 0)
        case .CharacterCreationScreen:
            return CGPoint(x: 4, y: 4)
        case .CharacterCustomizationScreen:
            return CGPoint(x: 3, y: 3)
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
        case .MultiplayerJoinRoomScreen:
            return CGPoint(x: -1, y: 2)
        case .MultiplayerLobby:
            return CGPoint(x: -1, y: 3)
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
    private(set) var currentViewController: ViewControllerProtocol
    
    init(with route: Route) {
        transitionHandler = RouteTransitionHandler(route: route)
        currentViewController = Router.getControllerFor(route: route)
        
        transitionHandler.subscribe { route in
            self.currentViewController = Router.getControllerFor(route: route)
        }
    }
    
    static func getControllerFor(route: Route) -> ViewControllerProtocol {
        switch(route) {
        case .TitleScreen:
            return TitleScreenViewController(with: UIView.initFromNib("TitleScreenView"))
        case .CharacterCreationScreen:
            return CharacterCreationViewController(with: UIView.initFromNib("CharacterCreationView"))
        case .CharacterCustomizationScreen:
            return CharacterCustomizationViewController(with: UIView.initFromNib("CharacterCustomizationView"))
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
        case .MultiplayerJoinRoomScreen:
            return JoinRoomViewController(with: UIView.initFromNib("JoinRoomView"))
        case .MultiplayerLobby:
            return MultiplayerLobbyViewController(with: UIView.initFromNib("MultiplayerLobbyView"))
        case .LoadingScreen:
            return LoadingScreenViewController(with: UIView.initFromNib("LoadingScreenView"))
        }
    }
    
    func routeTo(_ route: Route)  {
        transitionHandler.onNext(route)
    }
}
