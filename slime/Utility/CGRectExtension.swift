//
//  CGRectExtension.swift
//  slime
//
//  Created by Gabriel Tan on 13/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

extension CGRect {
    // Scales the rectangle by a scale factor.
    func scale(by factor: CGFloat) -> CGRect {
        return CGRect(x: minX, y: minY, width: width * factor, height: height * factor)
    }
    
    // Scales the width of the rectangle.
    func scaleX(by factor: CGFloat) -> CGRect {
        return CGRect(x: minX, y: minY, width: width * factor, height: height)
    }
    
    // Scales the height of the rectangle.
    func scaleY(by factor: CGFloat) -> CGRect {
        return CGRect(x: minX, y: minY, width: width, height: height * factor)
    }

    // Returns a CGRect with only the x value changed.
    func withX(x: CGFloat) -> CGRect {
        return CGRect(x: x, y: minY, width: width, height: height)
    }

    // Returns a CGRect with only the y value changed.
    func withY(y: CGFloat) -> CGRect {
        return CGRect(x: minX, y: y, width: width, height: height)
    }
}
