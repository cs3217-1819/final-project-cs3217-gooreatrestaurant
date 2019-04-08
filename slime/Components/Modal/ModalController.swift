//
//  ModalController.swift
//  slime
//
//  Created by Gabriel Tan on 18/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

class ModalController: Controller {
    private let disposeBag = DisposeBag()
    let view: UIView
    var innerView: UIView?
    var backgroundView: UIView?

    // Wraps a modal around the given view
    init() {
        view = UIView.initFromNib("Modal")
    }

    func setContent(_ view: UIView) {
        if let contentView = innerView {
            contentView.removeFromSuperview()
        }
        innerView = view
    }

    func configure() {
        guard let trueInnerView = innerView else {
            return
        }
        view.addSubview(trueInnerView)
        view.snp.makeConstraints { make in
            make.size.equalTo(trueInnerView)
        }
    }

    func openWithoutBase(with parent: UIView) {
        guard let actualView = innerView else {
            return
        }
        let background = createBackground(for: parent, closeOnOutsideTap: true)
        actualView.alpha = 0
        parent.addSubview(actualView)
        UIView.animate(withDuration: TransitionConstants.inTime, animations: {
            actualView.alpha = 1
            background.alpha = 1
        })
    }

    func open(with parent: UIView) {
        open(with: parent, closeOnOutsideTap: true)
    }

    func open(with parent: UIView, closeOnOutsideTap: Bool) {
        let background = createBackground(for: parent, closeOnOutsideTap: closeOnOutsideTap)
        view.alpha = 0
        parent.addSubview(view)
        view.centerInParent()
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, animations: {
            self.view.alpha = 1
            background.alpha = 1
        })
    }

    func close() {
        view.alpha = 1
        UIView.animate(withDuration: 0.3, animations: {
            self.view.alpha = 0
            self.backgroundView?.alpha = 0
        }, completion: { _ in
            self.view.removeFromSuperview()
            self.backgroundView?.removeFromSuperview()
            self.backgroundView = nil
        })
    }

    private func createBackground(for parent: UIView, closeOnOutsideTap: Bool) -> UIView {
        let background = UIView(frame: parent.frame)
        backgroundView = background
        background.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        background.alpha = 0
        background.rx.gesture(.tap())
            .when(.recognized)
            .subscribe { _ in
                if closeOnOutsideTap {
                    print("should close")
                    self.close()
                }
            }.disposed(by: disposeBag)
        parent.addSubview(background)
        return background
    }
}
