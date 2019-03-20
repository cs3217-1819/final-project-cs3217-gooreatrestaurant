//
//  Context.swift
//  slime
//
//  Created by Gabriel Tan on 18/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class Context {
    let router = Router(with: .TitleScreen)
    private var baseView: UIView {
        return viewController.view
    }
    private let viewController: UIViewController
    private let modal = ModalController()
    
    init(using viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func showModal(view: UIView) {
        modal.setContent(view)
        modal.configure()
        modal.open(with: baseView)
    }
    
    func closeModal() {
        modal.close()
    }
    
    func createAlert() -> AlertController {
        return AlertController(using: modal)
    }
    
    func presentAlert(_ alert: AlertController) {
        alert.configure()
        modal.configure()
        modal.open(with: baseView, closeOnOutsideTap: false)
    }
    
    func presentUnimportantAlert(_ alert: AlertController) {
        alert.configure()
        modal.configure()
        modal.open(with: baseView, closeOnOutsideTap: true)
    }
    
    func segueToGame() {
        viewController.performSegue(withIdentifier: "toGame", sender: nil)
    }
}
