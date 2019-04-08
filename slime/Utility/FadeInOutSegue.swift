//
//  FadeInOutSegue.swift
//  slime
//
//  Created by Johandy Tantra on 21/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//
import UIKit

class FadeInOutSegue: UIStoryboardSegue {
    override func perform() {
        let toViewController = self.destination
        let fromViewController = self.source

        guard let fromView = fromViewController.view.superview else {
            // TODO: add appropriate error
            return
        }

        // adds next view to current subview
        fromView.addSubview(toViewController.view)

        // before animations
        toViewController.view.alpha = 0

        UIView.animateKeyframes(withDuration: 2.0, delay: 0, options: .calculationModeLinear, animations: {
            // from VC animation
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1.0/2.0, animations: {
                fromViewController.view.alpha = 0
            })

            // to VC animation
            UIView.addKeyframe(withRelativeStartTime: 1.0/2.0, relativeDuration: 1.0/2.0, animations: {
                toViewController.view.alpha = 1
            })
        }) { (_) in
            fromViewController.present(toViewController, animated: false, completion: nil)
        }
    }
}
