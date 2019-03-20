//
//  ScrollingBackgroundViewController.swift
//  slime
//
//  Created by Gabriel Tan on 13/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class ScrollingBackgroundViewController {
    private let background: UIImageView
    
    init(with view: UIView) {
        background = UIImageView(frame: view.frame.scale(by: 2))
        background.frame = background.frame.offsetBy(dx: -view.frame.width, dy: -view.frame.height)
        background.image = ImageProvider.get("background")
        
        UIView.animate(withDuration: 10.0, delay: 0.0, options: [.repeat, .autoreverse], animations: {
            self.background.frame = self.background.frame.offsetBy(dx: view.frame.width, dy: view.frame.height)
        }, completion: nil)
        view.addSubview(background)
        view.sendSubviewToBack(background)
    }
    
    func toAlpha(_ alpha: CGFloat) {
        UIView.animate(withDuration: 0.5, animations: {
            self.background.alpha = alpha
        })
    }
    
    deinit {
        background.removeFromSuperview()
    }
}
