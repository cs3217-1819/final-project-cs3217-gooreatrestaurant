//
//  ContextModalHandler.swift
//  slime
//
//  Created by Gabriel Tan on 3/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import RxSwift

// Handles modal and alerts showing.
class ContextModalHandler {
    private let baseView: UIView
    private var modalStack: [AnyObject] = []

    init(baseView: UIView) {
        self.baseView = baseView
    }

    // Shows a view on the screen.
    func showView(view: UIView) {
        let controller = ModalController()
        controller.setContent(view)
        controller.configure()
        controller.openWithoutBase(with: baseView)
        remember(controller)
    }

    // Shows a modal that can be closed by tapping outside the modal.
    func showModal(view: UIView) {
        showModal(view: view, closeOnOutsideTap: true)
    }

    // Shows a modal.
    func showModal(view: UIView, closeOnOutsideTap: Bool) {
        let controller = ModalController()
        controller.setContent(view)
        controller.configure()
        controller.open(with: baseView, closeOnOutsideTap: closeOnOutsideTap)
        remember(controller)
    }

    // Creates an alert to be presented later on.
    func createAlert() -> AlertController {
        let controller = ModalController()
        return AlertController(using: controller)
    }

    // Present the given alert controller.
    func presentAlert(_ alert: AlertController) {
        alert.configure()
        alert.modalController.configure()
        alert.modalController.open(with: baseView, closeOnOutsideTap: false)
        remember(alert)
    }

    // Present an alert which can be closed by tapping outside the alert.
    func presentUnimportantAlert(_ alert: AlertController) {
        alert.configure()
        alert.modalController.configure()
        alert.modalController.open(with: baseView, closeOnOutsideTap: true)
        remember(alert)
    }

    // Remember past alerts and modals, but limited to 5 active modals.
    private func remember<T: Controller>(_ controller: T) {
        modalStack.append(controller)
        if modalStack.count > 5 {
            _ = modalStack.removeFirst()
        }
    }

    // Close all alerts and modals.
    func closeAllModals() {
        modalStack.forEach { control in
            if let modal = control as? ModalController {
                modal.close()
            } else if let alert = control as? AlertController {
                alert.modalController.close()
            }
        }
        modalStack = []
    }
}
