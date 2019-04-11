//
//  SlimeColor.swift
//  slime
//
//  Created by Gabriel Tan on 1/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

@objc enum SlimeColor: Int, CaseIterable {
    case yellow
    case blue
    case red
    case green
    case orange
    
    init(fromString colorString: String) {
        switch(colorString) {
        case "yellow":
            self = .yellow
        case "blue":
            self = .blue
        case "red":
            self = .red
        case "green":
            self = .green
        case "orange":
            self = .orange
        default:
            self = .green
        }
    }
    
    func toString() -> String {
        switch(self) {
        case .yellow:
            return "yello"
        case .blue:
            return "blue"
        case .red:
            return "red"
        case .green:
            return "green"
        case .orange:
            return "orange"
        }
    }

    func getImage() -> UIImage? {
        switch(self) {
        case .yellow:
            return ImageProvider.get("slime-yellow")
        case .blue:
            return ImageProvider.get("slime-blue")
        case .red:
            return ImageProvider.get("slime-red")
        case .green:
            return ImageProvider.get("slime-green")
        case .orange:
            return ImageProvider.get("slime-orange")
        }
    }
}
