//
//  DesignableView.swift
//  slime
//
//  Created by Gabriel Tan on 20/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

@IBDesignable
class DesignableView: UIView {
    @IBInspectable var rounded: Bool = false {
        didSet {
            if rounded {
                layer.cornerRadius = 8
            } else {
                layer.cornerRadius = 0
            }
        }
    }
    
    @IBInspectable var background: String = "" {
        didSet {
            if let color = ColorStyles.getColor(background) {
                backgroundColor = color
            }
        }
    }
}
