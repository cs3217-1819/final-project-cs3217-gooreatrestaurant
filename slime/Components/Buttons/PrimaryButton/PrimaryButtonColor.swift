//
//  PrimaryButtonColor.swift
//  slime
//
//  Created by Gabriel Tan on 14/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

enum PrimaryButtonColor {
    case purple
    case green
    case blue

    static func from(string: String) -> PrimaryButtonColor? {
        switch(string) {
        case "purple":
            return .purple
        case "green":
            return .green
        case "blue":
            return .blue
        default:
            return nil
        }
    }

    var image: UIImage? {
        switch (self) {
        case .purple:
            return ImageProvider.get("button-purple")
        case .blue:
            return ImageProvider.get("button-blue")
        case .green:
            return ImageProvider.get("button-green")
        }
    }
}
