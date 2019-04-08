//
//  NumberPadResponder.swift
//  slime
//
//  Created by Gabriel Tan on 27/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

protocol NumberPadResponder {
    // Input is any number from 0 - 9
    func respondTo(_ input: Int)
    func respondToBackspace()
    func respondToClear()
}
