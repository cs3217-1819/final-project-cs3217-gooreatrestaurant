//
//  RatingViewController.swift
//  slime
//
//  Created by Gabriel Tan on 25/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import RxSwift

class RatingViewController: Controller {
    let view: RatingView
    let observableRating: BehaviorSubject<Int>
    lazy private var emptyImage = UIImage(named: "rating-empty")
    lazy private var fullImage = UIImage(named: "rating-full")

    private let disposeBag = DisposeBag()

    init(with view: UIView, rating: Int) {
        guard let trueView = view as? RatingView else {
            fatalError("Nib class is wrong")
        }
        self.view = trueView
        observableRating = BehaviorSubject(value: rating)
    }

    init(with xibView: XibView, rating: Int) {
        guard let trueView = xibView.contentView as? RatingView else {
            fatalError("Nib class is wrong")
        }
        self.view = trueView
        self.observableRating = BehaviorSubject(value: rating)
    }

    func configure() {
        guard let value = try? observableRating.value() else {
            return
        }
        configureRating(value)
        observableRating.distinctUntilChanged().subscribe { event in
            guard let newRating = event.element else {
                return
            }

            self.configureRating(newRating)
        }.disposed(by: disposeBag)
    }

    private func configureRating(_ rating: Int) {
        if rating >= 1 {
            view.firstView.image = fullImage
        } else {
            view.firstView.image = emptyImage
        }

        if rating >= 2 {
            view.secondView.image = fullImage
        } else {
            view.secondView.image = emptyImage
        }

        if rating >= 3 {
            view.thirdView.image = fullImage
        } else {
            view.thirdView.image = emptyImage
        }
    }
}
