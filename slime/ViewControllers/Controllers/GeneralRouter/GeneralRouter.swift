//
//  GeneralRouter.swift
//  slime
//
//  Created by Gabriel Tan on 4/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import Foundation
import UIKit

class GeneralRouter<RouteType> {
    init(routes: [String: RouteManager]) {
        
    }
}

class RouteManager {
    let nibName: String
    init(nibName: String) {
        self.nibName = nibName
    }
    
    func createController<Control: ViewControllerProtocol>() -> Control {
        return UIView.initFromNib(nibName) as! Control
    }
}
