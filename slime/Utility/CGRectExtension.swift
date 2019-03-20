//
//  CGRectExtension.swift
//  slime
//
//  Created by Gabriel Tan on 13/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

extension CGRect {
    func scale(by factor: CGFloat) -> CGRect {
        return CGRect(x: minX, y: minY, width: width * factor, height: height * factor)
    }
    
    func withX(x: CGFloat) -> CGRect {
        return CGRect(x: x, y: minY, width: width, height: height)
    }
    
    func withY(y: CGFloat) -> CGRect {
        return CGRect(x: minX, y: y, width: width, height: height)
    }
}
