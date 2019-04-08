//
//  ContextModalHandler.swift
//  slime
//
//  Created by Gabriel Tan on 3/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import RxSwift

class ContextModalHandler {
    private let baseView: UIView
    private var modalStack: [AnyObject] = []

    init(baseView: UIView) {
        self.baseView = baseView
    }

    func showView(view: UIView) {
        let controller = ModalController()
        controller.setContent(view)
        controller.configure()
        controller.openWithoutBase(with: baseView)
        remember(controller)
    }

    func showModal(view: UIView) {
        showModal(view: view, closeOnOutsideTap: true)
    }

    func showModal(view: UIView, closeOnOutsideTap: Bool) {
        let controller = ModalController()
        controller.setContent(view)
        controller.configure()
        controller.open(with: baseView, closeOnOutsideTap: closeOnOutsideTap)
        remember(controller)
    }

    func createAlert() -> AlertController {
        let controller = ModalController()
        return AlertController(using: controller)
    }

    func presentAlert(_ alert: AlertController) {
        alert.configure()
        alert.modalController.configure()
        alert.modalController.open(with: baseView, closeOnOutsideTap: false)
        remember(alert)
    }

    func presentUnimportantAlert(_ alert: AlertController) {
        alert.configure()
        alert.modalController.configure()
        alert.modalController.open(with: baseView, closeOnOutsideTap: true)
        remember(alert)
    }

    private func remember<T: Controller>(_ controller: T) {
        modalStack.append(controller)
        if modalStack.count > 5 {
            _ = modalStack.removeFirst()
        }
    }

    func closeAlert() {
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
