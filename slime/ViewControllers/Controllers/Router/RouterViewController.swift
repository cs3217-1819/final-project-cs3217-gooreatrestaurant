//
//  RouterViewController.swift
//  slime
//
//  Created by Gabriel Tan on 15/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import RxSwift

// Base protocol for all pseudo-VCs used in routing
protocol RouterViewController {
    // The RouterVC must take in a view where it uses as its base view.
    init(with view: UIView)
    
    // configureSubviews is called after the RouterVC is initialized.
    // Do all setup here.
    func configureSubviews()
    
    // onDisappear is called when the RouterVC is no longer being used.
    // Use it to cleanup resources.
    func onDisappear()
    
    // Return the base view of the RouterVC.
    func getView() -> UIView
}
