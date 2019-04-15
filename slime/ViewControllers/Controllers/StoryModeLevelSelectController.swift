//
//  StoryModeLevelSelectController.swift
//  slime
//
//  Created by Gabriel Tan on 15/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class StoryModeLevelSelectController: ViewController<StoryModeLevelSelectView>,
    UIScrollViewDelegate {
    private var dotControllers: [LevelPlaceController] = []
    private var levels: [Level] = []
    private var currentDotIndex = 0

    required init(with view: UIView) {
        super.init(with: view)
        levels = getLevels()
    }

    override func configureSubviews() {
        view.constraintToParent()
        view.layoutIfNeeded()
        configureScrollView()
        configureDots()
    }

    private func getLevels() -> [Level] {
        return LevelsReader.readSinglePlayerLevels()
    }

    func configureScrollView() {
        view.scrollView.constraintToParent()
        view.scrollView.layoutIfNeeded()
        view.scrollView.delegate = self
    }

    func configureDots() {
        var contentRect: CGRect = CGRect.zero
        for (idx, level) in levels.enumerated() {
            let dotController = LevelPlaceController(with: view.scrollView, using: level, index: idx, context: context)
            dotController.configure()
            view.scrollView.addSubview(dotController.view)
            contentRect = contentRect.union(dotController.view.frame)

            dotControllers.append(dotController)
        }

        view.scrollView.contentSize = CGSize(width: contentRect.width, height: contentRect.height + view.scrollView.frame.height / 2)

        dotControllers[0].focus()
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        var bestDiff: CGFloat = CGFloat.infinity
        var bestDot: LevelPlaceController?
        var bestIndex: Int = 0
        for (idx, dotController) in dotControllers.enumerated() {
            guard let diff = dotController.getScrollOffsetDiff(contentOffsetY: scrollView.contentOffset.y) else {
                continue
            }
            if diff < bestDiff {
                bestDiff = diff
                bestDot = dotController
                bestIndex = idx
            }
        }

        guard let offsetValue = bestDot?.offsetValue else {
            return
        }

        targetContentOffset.pointee = offsetValue

        if currentDotIndex == bestIndex {
            // No change in view
            return
        }

        currentDotIndex = bestIndex

        for (idx, control) in dotControllers.enumerated() {
            if idx != bestIndex {
                control.unfocus()
            } else {
                control.focus()
            }
        }
    }
}
