//
//  RouterController.swift
//  slime
//
//  Created by Gabriel Tan on 7/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class RouterController: Controller {
    enum Direction {
        case up
        case down
        case left
        case right
    }
    
    let view: UIView
    private var childView: UIView
    
    init(with view: UIView, childView: UIView) {
        self.view = view
        self.childView = childView
    }
    
    func configure() {
        view.layer.masksToBounds = true
        childView.removeFromSuperview()
        view.addSubview(childView)
        childView.constraintToParent()
    }
    
    func setView(_ newView: UIView, direction: Direction) {
        setView(newView, direction: direction, onComplete: { })
    }
    
    func setView(_ newView: UIView, direction: Direction, onComplete: @escaping () -> ()) {
        let coordsDiff = getCoordsDiff(direction: direction)
        let frameSize = CGPoint(x: view.frame.width, y: view.frame.height)
        // points based on scale of screen size
        let diff = coordsDiff .* frameSize
        
        newView.frame = CGRect(x: diff.x, y: diff.y, width: view.frame.width, height: view.frame.height)
        newView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(newView)
        
        let fromFrame = childView.frame
        UIView.animate(withDuration: TransitionConstants.inTime, animations: {
            self.childView.frame = fromFrame.offsetBy(dx: -diff.x, dy: -diff.y)
            newView.frame = newView.frame.offsetBy(dx: -diff.x, dy: -diff.y)
        })
        
        Timer.scheduledTimer(withTimeInterval: TransitionConstants.inTime, repeats: false, block: { _ in
            self.childView.removeFromSuperview()
            self.childView = newView
            onComplete()
        })
    }
    
    private func getCoordsDiff(direction: Direction) -> CGPoint {
        switch(direction) {
        case .up:
            return CGPoint(x: 0, y: 1)
        case .down:
            return CGPoint(x: 0, y: -1)
        case .left:
            return CGPoint(x: -1, y: 0)
        case .right:
            return CGPoint(x: 1, y: 0)
        }
    }
}
