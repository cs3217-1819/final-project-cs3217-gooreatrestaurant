//
//  Controller.swift
//  slime
//
//  Created by Gabriel Tan on 27/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

// A general Controller protocol for all controllers
protocol Controller: AnyObject {
    associatedtype View: UIView
    var view: View { get }
    func configure()
}
