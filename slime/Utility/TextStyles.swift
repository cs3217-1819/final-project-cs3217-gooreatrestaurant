//
//  TextStyles.swift
//  slime
//
//  Created by Gabriel Tan on 14/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class TextStyles {
    private static let titleFontName = "SquidgySlimes"
    private static let readingFontName = "Rubik-Regular"
    static let headerStyles: [String: CGFloat] = [
        "h0": 34,
        "h1": 28,
        "h2": 22,
        "h3": 20,
        "hsub": 16
    ]
    static let textStyles: [String: CGFloat] = [
        "p0": 22,
        "p1": 18,
        "p2": 16,
        "psmall": 14
    ]

    static func getStyle(_ label: String) -> UIFont? {
        if let size = headerStyles[label] {
            return getTitleFont(size: size)
        }
        if let size = textStyles[label] {
            return getReadingFont(size: size)
        }

        return nil
    }

    private static func getTitleFont(size: CGFloat) -> UIFont {
        return getFont(name: titleFontName, size: size)
    }

    private static func getReadingFont(size: CGFloat) -> UIFont {
        return getFont(name: readingFontName, size: size)
    }

    // Tries to get font, fatal error if cannot find font.
    private static func getFont(name: String, size: CGFloat) -> UIFont {
        guard let font = UIFont(name: name, size: size) else {
            fatalError("Font \(name) not found")
        }
        return font
    }
}
