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

class ModalController {
    private let disposeBag = DisposeBag()
    let modalView: UIView
    var innerView: UIView?
    var backgroundView: UIView?
    
    // Wraps a modal around the given view
    init() {
        modalView = UIView.initFromNib("Modal")
    }
    
    func setContent(_ view: UIView) {
        if let contentView = innerView {
            contentView.removeFromSuperview()
        }
        innerView = view
    }
    
    func configure() {
        guard let view = innerView else {
            return
        }
        modalView.addSubview(view)
        modalView.snp.makeConstraints { make in
            make.size.equalTo(view)
        }
    }
    
    func open(with parent: UIView) {
        open(with: parent, closeOnOutsideTap: true)
    }
    
    func open(with parent: UIView, closeOnOutsideTap: Bool) {
        let background = createBackground(for: parent, closeOnOutsideTap: closeOnOutsideTap)
        modalView.alpha = 0
        parent.addSubview(modalView)
        modalView.centerInParent()
        modalView.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, animations: {
            self.modalView.alpha = 1
            background.alpha = 1
        })
    }
    
    func close() {
        modalView.alpha = 1
        UIView.animate(withDuration: 0.3, animations: {
            self.modalView.alpha = 0
            self.backgroundView?.alpha = 0
        }, completion: { _ in
            self.modalView.removeFromSuperview()
            self.backgroundView?.removeFromSuperview()
            self.backgroundView = nil
        })
    }
    
    private func createBackground(for parent: UIView, closeOnOutsideTap: Bool) -> UIView {
        let background = UIView(frame: parent.frame)
        backgroundView = background
        background.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        background.alpha = 0
        parent.addSubview(background)
        background.rx.gesture(.tap())
            .when(.recognized)
            .subscribe { _ in
                if closeOnOutsideTap {
                    self.close()
                }
            }.disposed(by: disposeBag)
        return background
    }
}
