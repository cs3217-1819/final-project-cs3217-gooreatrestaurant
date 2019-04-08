//
//  AlertController.swift
//  slime
//
//  Created by Gabriel Tan on 19/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class AlertController: Controller {
    let view: Alert
    let modalController: ModalController
    private var title: String?
    private var description: String?
    private var actions: [AlertAction] = []
    private var controllers: [AnyObject] = []

    init(using modalController: ModalController) {
        view = UIView.initFromNib("Alert")
        self.modalController = modalController
    }

    func setTitle(_ title: String) -> AlertController {
        self.title = title
        return self
    }

    func setDescription(_ description: String) -> AlertController {
        self.description = description
        return self
    }

    func addAction(_ action: AlertAction) -> AlertController {
        actions.append(action)
        return self
    }

    func configure() {
        view.titleLabel.text = title
        view.descriptionLabel.text = description
        for action in actions {
            let actionView = UIView.initFromNib("PrimaryButton")
            let controller = PrimaryButtonController(using: actionView)
            controller.configure()
            _ = controller
                .set(label: action.label)
            switch(action.type) {
            case .Normal:
                _ = controller.set(color: .blue)
            case .Success:
                _ = controller.set(color: .green)
            case .Danger:
                _ = controller.set(color: .purple)
            }
            controller.onTap {
                action.callback()
                self.modalController.close()
            }

            view.actionStackView.addArrangedSubview(actionView)
        }

        view.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(450)
            make.height.lessThanOrEqualTo(300)
        }
        view.layoutIfNeeded()
        modalController.setContent(view)
    }

    func remember(_ controller: AnyObject) {
        controllers.append(controller)
    }
}
