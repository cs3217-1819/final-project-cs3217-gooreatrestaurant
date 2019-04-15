//
//  LevelPlaceController.swift
//  slime
//
//  Created by Gabriel Tan on 16/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import RxSwift

class LevelPlaceController: Controller {
    let view: LevelPlaceView
    private(set) var offsetValue: CGPoint?

    private let disposeBag = DisposeBag()
    private let isActive = BehaviorSubject(value: false)
    private let parent: UIScrollView
    private let boxController: LevelDetailsBoxController
    private var playButtonController: ButtonController?
    private let level: Level
    private let index: Int
    private let context: Context

    // Creates the nib for you
    init(with parent: UIScrollView, using level: Level, index: Int, context: Context) {
        guard let trueView = UIView.initFromNib("LevelPlaceView") as? LevelPlaceView else {
            fatalError("Nib class is wrong")
        }
        view = trueView
        self.parent = parent
        self.level = level
        self.index = index
        self.context = context

        boxController = LevelDetailsBoxController(using: view.detailsBox)
        boxController.configure()
    }

    func configure() {
        let frameSize = view.frame.size
        let start = CGPoint(x: parent.frame.midX - frameSize.width / 2,
                            y: parent.bounds.height / 2 - frameSize.height / 2)
        let offset = CGPoint(x: 0.0, y: CGFloat(index) * view.frame.height)
        offsetValue = offset
        let center = start + offset

        view.frame = view.frame.offsetBy(dx: center.x, dy: center.y)

        _ = boxController
            .set(id: level.id)
            .set(name: level.name)
            .set(bestScore: level.bestScore)

        playButtonController = ButtonController(using: view.playButton)
        playButtonController?.onTap {
            self.context.routeToAndPrepareFor(.LoadingScreen, callback: { vc in
                let loadingVC = vc as! LoadingScreenViewController
                loadingVC.setLevelToLoad(self.level)
            })
        }

        isActive.asObservable().distinctUntilChanged().subscribe { event in
            guard let isActive = event.element else {
                return
            }
            if isActive {
                self.moveToCenter()
                self.showPlayButton()
            } else {
                self.moveRandom()
                self.hidePlayButton()
            }
        }.disposed(by: disposeBag)

        view.layoutIfNeeded()
    }

    // Moves the x-coordinates randomly
    private func moveRandom() {
        let range = parent.bounds.width - view.frame.size.width
        let randomX = CGFloat.random(in: (0.2 * range)...(0.8 * range))
        UIView.animate(withDuration: 0.5, animations: {
            self.view.frame = self.view.frame.withX(x: randomX)
        })
    }

    private func moveToCenter() {
        UIView.animate(withDuration: 0.5, animations: {
            self.view.frame = self.view.frame.withX(x: self.parent.frame.midX - self.view.frame.size.width / 2)
        })
    }

    private func showPlayButton() {
        UIView.animate(withDuration: 0.5, animations: {
            self.view.playButton.contentView?.alpha = 1
        })
    }

    private func hidePlayButton() {
        UIView.animate(withDuration: 0.5, animations: {
            self.view.playButton.contentView?.alpha = 0
        })
    }

    func focus() {
        isActive.onNext(true)
    }

    func unfocus() {
        isActive.onNext(false)
    }

    func getScrollOffsetDiff(contentOffsetY: CGFloat) -> CGFloat? {
        guard let offsetY = offsetValue?.y else {
            return nil
        }
        return abs(offsetY - contentOffsetY)
    }
}
