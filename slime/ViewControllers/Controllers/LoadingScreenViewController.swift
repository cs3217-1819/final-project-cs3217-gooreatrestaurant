//
//  LoadingScreenViewController.swift
//  slime
//
//  Created by Gabriel Tan on 20/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//
import Foundation

class LoadingScreenViewController: ViewController<LoadingScreenView> {
    override func configureSubviews() {
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { _ in
            self.context.segueToGame()
        })
    }
}
