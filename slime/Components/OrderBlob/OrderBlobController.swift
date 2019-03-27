//
//  OrderBlobController.swift
//  slime
//
//  Created by Gabriel Tan on 23/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class OrderBlobController: Controller {
    let view: OrderBlob
    private let parent: UIStackView
    private let recipe: OrderBlobRecipe
    
    // Creates the nib for you
    init(parent: UIStackView, recipe: OrderBlobRecipe) {
        guard let view = UIView.initFromNib("OrderBlob") as? OrderBlob else {
            fatalError("Nib class is wrong")
        }
        self.view = view
        self.parent = parent
        self.recipe = recipe
    }
    
    func configure() {
        view.orderGoal.image = ImageProvider.get(recipe.goalImageName)
        for instruction in recipe.instructionsImageNames {
            let imageView = UIImageView(image: ImageProvider.get(instruction))
            view.orderInstructions.addArrangedSubview(imageView)
        }
        
        parent.addArrangedSubview(view)
    }
    
    deinit {
        view.removeFromSuperview()
    }
}
