//
//  SettingsScreenViewController.swift
//  slime
//
//  Created by Gabriel Tan on 18/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class SettingsScreenViewController: ViewController<SettingsScreenView> {
    override func configureSubviews() {
        let control = ButtonController(using: view.backButton)
        control.onTap {
            // TODO: Change back to title screen
            // self.router.routeTo(.TitleScreen)
            self.attachNewRecipe()
        }
        remember(control)
        
        
    }
    
    private func attachNewRecipe() {
        let recipe = OrderBlobRecipe(goalImageName: "recipe-knife", instructionsImageNames: [
            "recipe-knife",
            "recipe-knife",
            "recipe-knife"
            ])
        let recipeController = OrderBlobController(parent: view.recipeBlobs, recipe: recipe)
        recipeController.configure()
        remember(recipeController)
    }
}
