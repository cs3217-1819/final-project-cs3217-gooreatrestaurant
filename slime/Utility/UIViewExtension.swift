//
//  UIViewExtension.swift
//  slime
//
//  Created by Gabriel Tan on 13/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import SnapKit

extension UIView {
    
    // Initialize an UIView from a nib.
    class func initFromNib<T: UIView>(_ string: String) -> T {
        guard let nib = Bundle.main.loadNibNamed(string, owner: nil, options: nil)?[0] as? T else {
            fatalError("Unable to load nib")
        }
        return nib
    }

    // Constraints all four sides to the parent.
    func constraintToParent() {
        self.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
        }
    }

    // Constraints all four sides to the parent with a given padding.
    func constraintToParent(offset: CGFloat) {
        self.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(offset)
            make.left.equalToSuperview().offset(offset)
            make.bottom.equalToSuperview().offset(-offset)
            make.right.equalToSuperview().offset(-offset)
        }
    }

    // Centers the view to the parent by using AutoLayout constraints.
    func centerInParent() {
        self.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    // For debugging purposes: Set a blue border around the view.
    func debug() {
        layer.borderColor = UIColor.blue.cgColor
        layer.borderWidth = 2.0
    }

    // For debugging purposes: Set a green border around the view.
    func debug2() {
        layer.borderColor = UIColor.green.cgColor
        layer.borderWidth = 2.0
    }
}
