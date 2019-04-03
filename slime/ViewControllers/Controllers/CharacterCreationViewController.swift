//
//  CharacterCreationViewController.swift
//  slime
//
//  Created by Gabriel Tan on 30/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class CharacterCreationViewController: ViewController<CharacterCreationView> {
    override func configureSubviews() {
        let control = TextInputController(usingXib: view.nameInputView, context: context)
        control.configure()
        remember(control)
    }
}
