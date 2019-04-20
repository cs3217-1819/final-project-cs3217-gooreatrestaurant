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
    
    // Use a specified style from the styles list if possible.
    @IBInspectable var style: String = "" {
        didSet {
            font = TextStyles.getStyle(style)
        }
    }

    // Changes the text color to one from the colors list if possible.
    @IBInspectable var color: String = "" {
        didSet {
            guard let colorToSet = ColorStyles.getColor(color) else {
                return
            }
            textColor = colorToSet
        }
    }
    
    // Changes the stroke width of the text.
    @IBInspectable var strokeWidth: CGFloat = 0 {
        didSet {
            guard let strokeColor = ColorStyles.getColor("white3") else {
                return
            }
            let strokeTextAttributes : [NSAttributedString.Key : Any] = [
                NSAttributedString.Key.strokeColor : strokeColor,
                NSAttributedString.Key.strokeWidth : -strokeWidth,
            ] as [NSAttributedString.Key  : Any]
            
            guard let labelText = text else {
                return
            }
            let customizedText = NSMutableAttributedString(string: labelText,
                                                           attributes: strokeTextAttributes)
            attributedText = customizedText
        }
    }
}

/**
 * TextField is a utility UITextField class for using
 * custom text styles.
 */
@IBDesignable
class TextField: UITextField {
    // Changes the style of the text.
    @IBInspectable var style: String = "" {
        didSet {
            font = TextStyles.getStyle(style)
        }
    }

    // Changes the color of the text.
    @IBInspectable var color: String = "" {
        didSet {
            guard let colorToSet = ColorStyles.getColor(color) else {
                return
            }
            textColor = colorToSet
        }
    }
}
