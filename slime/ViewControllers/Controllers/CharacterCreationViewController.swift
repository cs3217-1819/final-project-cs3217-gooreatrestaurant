//
//  CharacterCreationViewController.swift
//  slime
//
//  Created by Gabriel Tan on 30/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class CharacterCreationViewController: ViewController<CharacterCreationView> {
    private var itemSelectController: ItemSelectorController<SlimeColor>?
    private var nameInputController: TextInputController?
    
    override func configureSubviews() {
        setupSelector()
        setupNameInput()
        setupButton()
    }
    
    private func setupSelector() {
        let control = ItemSelectorController<SlimeColor>(withXib: view.colorSelectionView)
        let items: [(SlimeColor, UIImage)] = SlimeColor.allCases
            .map { color in
                guard let image = color.getImage() else {
                    fatalError("Image not found for slime color")
                }
                return (color, image)
            }
        control.set(items: items)
        control.configure()
        itemSelectController = control
    }
    
    private func setupNameInput() {
        let control = TextInputController(usingXib: view.nameInputView, context: context)
        control.configure()
        nameInputController = control
    }
    
    private func setupButton() {
        let control = PrimaryButtonController(using: view.submitButton)
            .set(label: "OK")
            .set(color: .green)
        control.onTap {
            guard let selectedItem = self.itemSelectController?.value else {
                return
            }
            guard let name = self.nameInputController?.value else {
                return
            }
            self.context.data.createCharacter(named: name, color: selectedItem)
            self.context.routeTo(.TitleScreen)
        }
        control.configure()
        remember(control)
    }
}
