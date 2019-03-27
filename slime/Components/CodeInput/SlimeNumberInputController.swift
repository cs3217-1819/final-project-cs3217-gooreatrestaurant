//
//  SlimeNumberInputController.swift
//  slime
//
//  Created by Gabriel Tan on 27/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class SlimeNumberInputController: Controller {
    let view: SlimeNumberInputView
    let number: Int
    
    init(with view: UIView, number: Int) {
        guard let trueView = view as? SlimeNumberInputView else {
            fatalError("Nib class is wrong")
        }
        self.view = trueView
        self.number = number
    }
    
    func configure() {
        view.numberLabel.text = "\(number)"
    }
}
