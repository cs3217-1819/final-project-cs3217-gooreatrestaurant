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
    init(with view: UIView)
    func configureSubviews()
    func onDisappear()
    func getView() -> UIView
}

extension RouterViewController {
    func onDisappear() {
        getView().removeFromSuperview()
    }
}
