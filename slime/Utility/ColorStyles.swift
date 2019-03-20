//
//  ColorStyles.swift
//  slime
//
//  Created by Gabriel Tan on 14/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class ColorStyles {
    static let whites: [String: UIColor] = [
        "white1": UIColor.white(intensity: .one),
        "white2": UIColor.white(intensity: .two),
        "white3": UIColor.white(intensity: .three),
        "white4": UIColor.white(intensity: .four),
        "white5": UIColor.white(intensity: .five),
        "white6": UIColor.white(intensity: .six),
        "white7": UIColor.white(intensity: .seven),
        "white8": UIColor.white(intensity: .eight),
    ]
    static func getColor(_ colorCode: String) -> UIColor? {
        if let color = whites[colorCode] {
            return color
        }
        
        return nil
    }
}
