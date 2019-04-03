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
    
    @IBInspectable var rotation: String = "" {
        didSet {
            if rotation == "left" {
                transform = CGAffineTransform(rotationAngle: CGFloat.pi * 1.5)
            }
            if rotation == "down" {
                transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            }
            if rotation == "right" {
                transform = CGAffineTransform(rotationAngle: CGFloat.pi * 0.5)
            }
            if let n = NumberFormatter().number(from: rotation) {
                transform = CGAffineTransform(rotationAngle: CGFloat(truncating: n))
            }
        }
    }
}
