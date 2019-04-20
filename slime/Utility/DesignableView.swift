//
//  DesignableView.swift
//  slime
//
//  Created by Gabriel Tan on 20/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

// A view with common styles for toggling and setting.
@IBDesignable
class DesignableView: UIView {
    // Set the edges of the view to be rounded.
    @IBInspectable var rounded: Bool = false {
        didSet {
            if rounded {
                layer.cornerRadius = 8
            } else {
                layer.cornerRadius = 0
            }
        }
    }

    // Set the background of the colour to a specified colour.
    @IBInspectable var background: String = "" {
        didSet {
            if let color = ColorStyles.getColor(background) {
                backgroundColor = color
            }
        }
    }

    // Rotate the view by a certain angle, in radians, or
    // use directions to specify a preset rotation value.
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
    
    // Flips the view along its x-axis.
    @IBInspectable var flipX: Bool = false {
        didSet {
            if flipX {
                transform = CGAffineTransform(scaleX: -transform.a, y: transform.d)
            }
        }
    }
}
