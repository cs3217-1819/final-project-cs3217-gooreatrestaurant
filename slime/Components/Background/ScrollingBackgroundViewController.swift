//
//  ScrollingBackgroundViewController.swift
//  slime
//
//  Created by Gabriel Tan on 13/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class ScrollingBackgroundViewController: Controller {
    var view: UIView {
        return background
    }
    private let parent: UIView
    private let background: UIView
    private var backgroundImageView: UIImageView
    private var imageName: String

    init(with view: UIView) {
        parent = view
        imageName = "background"
        background = UIView(frame: view.frame.scale(by: 2))
        backgroundImageView = UIImageView(frame: background.frame)
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.frame = background.bounds
        background.addSubview(backgroundImageView)
    }

    func configure() {
        setupView(parent: parent)
        setupNotifier()
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
        newBackgroundImageView.contentMode = .scaleAspectFill
        newBackgroundImageView.frame = background.bounds
        newBackgroundImageView.alpha = 0
        newBackgroundImageView.image = newImage
        background.addSubview(newBackgroundImageView)
        self.imageName = imageNamed
        UIView.animate(withDuration: 1.0, animations: {
            self.backgroundImageView.alpha = 0
            newBackgroundImageView.alpha = 1
        }, completion: { _ in
            self.backgroundImageView.removeFromSuperview()
            self.backgroundImageView = newBackgroundImageView
        })
    }
    
    private func setupNotifier() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
    }
    
    @objc private func applicationDidBecomeActive(_ notification: NSNotification) {
        setupView(parent: parent)
    }

    private func setupView(parent: UIView) {
        background.contentMode = .scaleAspectFill
        background.frame = background.frame.offsetBy(dx: -parent.frame.width, dy: -parent.frame.height)
        backgroundImageView.image = ImageProvider.get(imageName)

        UIView.animate(withDuration: 10.0, delay: 0.0, options: [.repeat, .autoreverse], animations: {
            self.background.frame = self.background.frame.offsetBy(dx: parent.frame.width, dy: parent.frame.height)
        }, completion: nil)
        parent.addSubview(background)
        parent.sendSubviewToBack(background)
    }

    deinit {
        background.removeFromSuperview()
        NotificationCenter.default.removeObserver(self)
    }
}
