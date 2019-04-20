//
//  ContextController.swift
//  slime
//
//  Created by Gabriel Tan on 18/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

// A ContextController only needs to be able to take in a context.
protocol ContextController {
    func use(context: Context)
}
