//
//  CharacterCustomizationViewController.swift
//  slime
//
//  Created by Gabriel Tan on 7/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import RxSwift

class CharacterCustomizationViewController: ViewController<CharacterCustomizationView> {
    enum CustomizationRoute {
        case Main
    }
    
    private var route: BehaviorSubject<CustomizationRoute> = BehaviorSubject(value: .Main)
    
    override func configureSubviews() {
        view.routerPanel
    }
    
    override func onDisappear() {
        
    }
    
    private func setRoute(_ route: CustomizationRoute) {
        
    }
}
