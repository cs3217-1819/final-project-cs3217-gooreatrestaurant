//
//  DoubleExtension.swift
//  slime
//
//  Created by Gabriel Tan on 30/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import Foundation

extension Double {
    func clamp(from minBound: Double, to maxBound: Double) -> Double {
        if self < minBound {
            return minBound
        }
        if self > maxBound {
            return maxBound
        }
        return self
    }
}
