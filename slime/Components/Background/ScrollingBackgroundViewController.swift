//
//  ScrollingBackgroundViewController.swift
//  slime
//
//  Created by Gabriel Tan on 13/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class ScrollingBackgroundViewController {
    private let background: UIView
    private var backgroundImageView: UIImageView
    private var imageName: String
    
    init(with view: UIView) {
        imageName = "background"
        background = UIView(frame: view.frame.scale(by: 2))
        backgroundImageView = UIImageView(frame: background.frame)
        backgroundImageView.frame = background.bounds
        background.addSubview(backgroundImageView)
        setupView(view: view)
    }
    
    func toAlpha(_ alpha: CGFloat) {
        UIView.animate(withDuration: 0.5, animations: {
            self.background.alpha = alpha
        })
    }
    
    func transitionTo(_ imageNamed: String) {
        if imageName == imageNamed {
            // currently has same background
            return
        }
        guard let newImage = ImageProvider.get(imageNamed) else {
            return
        }
        let newBackgroundImageView = UIImageView(frame: background.frame)
        newBackgroundImageView.frame = background.bounds
        newBackgroundImageView.alpha = 0
        newBackgroundImageView.image = newImage
        background.addSubview(newBackgroundImageView)
        UIView.animate(withDuration: 1.0, animations: {
            self.backgroundImageView.alpha = 0
            newBackgroundImageView.alpha = 1
        }, completion: { _ in
            self.backgroundImageView.removeFromSuperview()
            self.backgroundImageView = newBackgroundImageView
            self.imageName = imageNamed
        })
    }
    
    private func setupView(view: UIView) {
        background.contentMode = .scaleAspectFill
        background.frame = background.frame.offsetBy(dx: -view.frame.width, dy: -view.frame.height)
        backgroundImageView.image = ImageProvider.get(imageName)
        
        UIView.animate(withDuration: 10.0, delay: 0.0, options: [.repeat, .autoreverse], animations: {
            self.background.frame = self.background.frame.offsetBy(dx: view.frame.width, dy: view.frame.height)
        }, completion: nil)
        view.addSubview(background)
        view.sendSubviewToBack(background)
    }
    
    deinit {
        background.removeFromSuperview()
    }
}
