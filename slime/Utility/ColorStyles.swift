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
        "white0": UIColor.white(intensity: .one),
        "white1": UIColor.white(intensity: .two),
        "white2": UIColor.white(intensity: .three),
        "white3": UIColor.white(intensity: .four),
        "white4": UIColor.white(intensity: .five),
        "white5": UIColor.white(intensity: .six),
        "white6": UIColor.white(intensity: .seven),
        "white7": UIColor.white(intensity: .eight),
    ]
    
    static let pinks: [String: UIColor] = [
        "pink0": UIColor(rgb: 0x995C7A),
        "pink1": UIColor(rgb: 0xB26B8F),
        "pink2": UIColor(rgb: 0xCC7AA3),
        "pink3": UIColor(rgb: 0xE58AB8),
        "pink4": UIColor(rgb: 0xFF99C8),
        "pink5": UIColor(rgb: 0xFFB1D5),
        "pink6": UIColor(rgb: 0xFFCAE2),
        "pink7": UIColor(rgb: 0xFFF5FA)
    ]
    
    static let greens: [String: UIColor] = [
        "green0": UIColor(rgb: 0x4D8060),
        "green1": UIColor(rgb: 0x74A687),
        "green2": UIColor(rgb: 0x93C4A6),
        "green3": UIColor(rgb: 0xB1DEC3),
        "green4": UIColor(rgb: 0xD0F4DE),
        "green5": UIColor(rgb: 0xDEFCEA),
        "green6": UIColor(rgb: 0xE5FBF6),
        "green7": UIColor(rgb: 0xF7FFFD)
    ]
    
    static let yellows: [String: UIColor] = [
        "yellow0": UIColor(rgb: 0xB27D47),
        "yellow1": UIColor(rgb: 0xD9B162),
        "yellow2": UIColor(rgb: 0xE5CC73),
        "yellow3": UIColor(rgb: 0xF2E59D),
        "yellow4": UIColor(rgb: 0xFCF6BD),
        "yellow5": UIColor(rgb: 0xFFFFC1),
        "yellow6": UIColor(rgb: 0xFFFFDE),
        "yellow7": UIColor(rgb: 0xFFFFEF)
    ]
    
    static let colorDicts = [
        whites,
        pinks,
        greens,
        yellows
    ]
    
    static func getColor(_ colorCode: String) -> UIColor? {
        for dict in colorDicts {
            if let color = dict[colorCode] {
                return color
            }
        }
        
        return nil
    }
}
