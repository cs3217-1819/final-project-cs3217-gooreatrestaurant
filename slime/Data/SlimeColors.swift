//
//  SlimeColor.swift
//  slime
//
//  Created by Gabriel Tan on 1/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

@objc enum SlimeColor: Int, CaseIterable {
    case yellow = 0
    case blue = 1
    case red = 2
    case green = 3
    case orange = 4
    
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
