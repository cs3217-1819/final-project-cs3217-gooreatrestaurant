//
//  CreditsSceneViewController.swift
//  slime
//
//  Created by Gabriel Tan on 17/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class CreditsSceneViewController: ViewController<CreditsScreenView> {
    required init(with view: UIView) {
        super.init(with: view)
    }
    
    override func configureSubviews() {
        UIView.animate(withDuration: 1, delay: 0, options: [.autoreverse, .repeat], animations: {
            self.view.huiqiLabel.frame = self.view.huiqiLabel.frame.offsetBy(dx: -50, dy: 0.0)
            self.view.gabrielLabel.frame = self.view.gabrielLabel.frame.offsetBy(dx: -70, dy: 0.0)
            self.view.anthonyLabel.frame = self.view.anthonyLabel.frame.offsetBy(dx: -60, dy: 0.0)
            self.view.henryLabel.frame = self.view.henryLabel.frame.offsetBy(dx: -80, dy: 0.0)
        }, completion: nil)
        
        let controller = ButtonController(using: view.backButton)
        controller.onTap {
            self.context.routeTo(.TitleScreen)
        }
        remember(controller)
    }
}
