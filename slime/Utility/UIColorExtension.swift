//
//  UIColorExtension.swift
//  slime
//
//  Created by Gabriel Tan on 14/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

enum ColorIntensity {
    case one
    case two
    case three
    case four
    case five
    case six
    case seven
    case eight
}

extension UIColor {
    // Takes in RGB hex code split into 3 parts
    // Example: UIColor(red: 0xFF, green: 0xAA, blue: 0xBB) would represent #FFAABB
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    // Convenient initialization from hex string
    // Example: UIColor(rgb: 0xFFAABB)
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }

    static func white(intensity: ColorIntensity) -> UIColor {
        switch(intensity) {
        case .one:
            return UIColor(rgb: 0x1C1C1C)
        case .two:
            return UIColor(rgb: 0x464646)
        case .three:
            return UIColor(rgb: 0x656565)
        case .four:
            return UIColor(rgb: 0x878787)
        case .five:
            return UIColor(rgb: 0xAFAFAF)
        case .six:
            return UIColor(rgb: 0xD0D0D0)
        case .seven:
            return UIColor(rgb: 0xE7E7E7)
        case .eight:
            return UIColor(rgb: 0xF4F4F4)
        }
    }
}
