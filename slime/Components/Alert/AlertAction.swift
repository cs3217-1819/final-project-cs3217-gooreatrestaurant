//
//  AlertAction.swift
//  slime
//
//  Created by Gabriel Tan on 19/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

class AlertAction {
    enum ActionType {
        case Normal
        case Success
        case Danger
    }

    let label: String
    let callback: () -> Void
    let type: ActionType

    init(with label: String, callback: @escaping () -> Void, of type: ActionType) {
        self.label = label
        self.callback = callback
        self.type = type
    }

    convenience init(with label: String, callback: @escaping () -> Void) {
        self.init(with: label, callback: callback, of: .Normal)
    }

    convenience init(with label: String) {
        self.init(with: label, callback: {})
    }
    
    convenience init(with label: String, of type: ActionType) {
        self.init(with: label, callback: {}, of: type)
    }
}
