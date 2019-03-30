//
//  UIText.swift
//  slime
//
//  Created by Gabriel Tan on 14/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

/**
 * TextLabel is a utility UILabel class for using
 * custom text styles.
 */
@IBDesignable
class TextLabel: UILabel {
    // Cannot have dropdown as it is not supported,
    // use String - check the styles enum for what strings
    // are accepted
    @IBInspectable var style: String = "" {
        didSet {
            font = TextStyles.getStyle(style)
        }
    }
    
    @IBInspectable var color: String = "" {
        didSet {
            guard let colorToSet = ColorStyles.getColor(color) else {
                return
            }
            textColor = colorToSet
        }
    }
}

/**
 * TextField is a utility UITextField class for using
 * custom text styles.
 */
@IBDesignable
class TextField: UITextField {
    @IBInspectable var style: String = "" {
        didSet {
            font = TextStyles.getStyle(style)
        }
    }
    
    @IBInspectable var color: String = "" {
        didSet {
            guard let colorToSet = ColorStyles.getColor(color) else {
                return
            }
            textColor = colorToSet
        }
    }
}
