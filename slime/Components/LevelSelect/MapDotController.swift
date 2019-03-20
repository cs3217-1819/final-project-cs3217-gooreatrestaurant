//
//  MapDotController.swift
//  slime
//
//  Created by Gabriel Tan on 16/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class MapDotController {
    private(set) var offsetValue: CGPoint?
    private(set) var view: UIView
    private let parent: UIScrollView
    private var dotSize: CGSize {
        let diameter = parent.frame.width / 12
        return CGSize(width: diameter, height: diameter)
    }
    private var detailsSize: CGSize {
        return CGSize(width: 200, height: 100)
    }
    private var playButtonSize: CGSize {
        return CGSize(width: 200, height: 40)
    }
    private var size: CGSize {
        return CGSize(width: dotSize.width + detailsSize.width + 16,
                      height: detailsSize.height + playButtonSize.height + 8)
    }
    private let boxController: LevelDetailsBoxController
    private var playButtonController: ButtonController?
    private let level: Level
    private let index: Int
    private let context: Context
    
    // Creates the nib for you
    init(with parent: UIScrollView, using level: Level, index: Int, context: Context) {
        view = UIView(frame: CGRect.zero)
        self.parent = parent
        self.level = level
        self.index = index
        self.context = context
        
        let mapDot = UIView.initFromNib("MapDot")
        let detailsBox = UIView.initFromNib("LevelDetailsBox")
        boxController = LevelDetailsBoxController(using: detailsBox)
        boxController.configure()
        
        view.addSubview(mapDot)
        view.addSubview(detailsBox)
        
        mapDot.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalTo(dotSize.width)
            make.height.equalTo(dotSize.height)
        }
        
        detailsBox.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(mapDot.snp.right).offset(16)
            make.height.equalTo(detailsSize.height)
            make.width.equalTo(detailsSize.width)
        }
    }
    
    func configure() {
        let start = CGPoint(x: parent.frame.midX - size.width / 2, y: parent.bounds.height / 2 - size.height / 2)
        let offset = CGPoint(x: 0.0, y: CGFloat(index) * parent.bounds.height / 2)
        offsetValue = offset
        let center = start + offset
        
        view.frame.size = size
        view.frame = view.frame.offsetBy(dx: center.x, dy: center.y)
        
        _ = boxController
            .set(id: level.id)
            .set(name: level.name)
            .set(bestScore: level.bestScore)
        
        view.layoutIfNeeded()
    }
    
    // Moves the x-coordinates randomly
    func moveRandom() {
        let range = parent.bounds.width - size.width
        let randomX = CGFloat.random(in: (0.2 * range)...(0.8 * range))
        UIView.animate(withDuration: 0.5, animations: {
            self.view.frame = self.view.frame.withX(x: randomX)
        })
    }
    
    func moveToCenter() {
        UIView.animate(withDuration: 0.5, animations: {
            self.view.frame = self.view.frame.withX(x: self.parent.frame.midX - self.size.width / 2)
        })
    }
    
    func focus() {
        let button = UIView.initFromNib("LevelPlayButton")
        playButtonController = ButtonController(using: button)
        playButtonController?.onTap {
            self.context.router.routeTo(.LoadingScreen)
        }
        parent.addSubview(button)
        button.snp.makeConstraints { make in
            make.top.equalTo(boxController.view.snp.bottom).offset(8)
            make.left.equalTo(boxController.view)
            make.right.equalTo(boxController.view)
            make.height.equalTo(40)
            make.width.equalTo(boxController.view)
        }
        button.transform = button.transform.scaledBy(x: 1 / 10, y: 1 / 10)
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, animations: {
            self.boxController.view.alpha = 1.0
            button.transform = button.transform.scaledBy(x: 10, y: 10)
        })
    }
    
    func unfocus() {
        UIView.animate(withDuration: 0.5, animations: {
            self.boxController.view.alpha = 0.2
            self.playButtonController?.view.transform = self.playButtonController!.view.transform.scaledBy(x: 0.1, y: 0.1)
        }, completion: { _ in
            self.playButtonController?.view.removeFromSuperview()
            self.playButtonController = nil
        })
    }
    
    func getScrollOffsetDiff(contentOffsetY: CGFloat) -> CGFloat? {
        guard let offsetY = offsetValue?.y else {
            return nil
        }
        return abs(offsetY - contentOffsetY)
    }
}
