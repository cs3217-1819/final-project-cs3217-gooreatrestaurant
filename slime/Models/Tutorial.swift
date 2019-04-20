//
//  Tutorial.swift
//  slime
//
//  Created by Gabriel Tan on 12/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

// Tutorial struct for displaying in the UI.
struct Tutorial {
    let image: UIImage?
    let title: String
    let description: String
    
    init(imageNamed imageName: String, title: String, description: String) {
        self.image = ImageProvider.get(imageName)
        self.title = title
        self.description = description
    }
}

// Constants for tutorials.
enum TutorialConstants {
    static let cutApple = [
        Tutorial(imageNamed: "tut-cutapple-step-1", title: "Step 1", description: "Tap the interact button when you are next to the apple station."),
        Tutorial(imageNamed: "tut-cutapple-step-2", title: "Step 2", description: "Move to the cutting station."),
        Tutorial(imageNamed: "tut-cutapple-step-3", title: "Step 3", description: "Tap the interact button until the cutting is done."),
        Tutorial(imageNamed: "tut-cutapple-step-4", title: "Step 4", description: "The apple is cut!")
    ]
}
