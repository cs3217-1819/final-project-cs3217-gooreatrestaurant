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
    class func initFromNib<T: UIView>(_ string: String) -> T {
        guard let nib = Bundle.main.loadNibNamed(string, owner: nil, options: nil)?[0] as? T else {
            fatalError("Unable to load nib")
        }
        return nib
    }
    
    func constraintToParent() {
        self.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
        }
    }
    
    func constraintToParent(offset: CGFloat) {
        self.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(offset)
            make.left.equalToSuperview().offset(offset)
            make.bottom.equalToSuperview().offset(-offset)
            make.right.equalToSuperview().offset(-offset)
        }
    }
    
    func centerInParent() {
        self.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    // debugging purposes
    func debug() {
        layer.borderColor = UIColor.blue.cgColor
        layer.borderWidth = 2.0
    }
    
    func debug2() {
        layer.borderColor = UIColor.green.cgColor
        layer.borderWidth = 2.0
    }
}
