//
//  ProgressBarController.swift
//  slime
//
//  Created by Gabriel Tan on 30/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import RxSwift

class ProgressBarController: Controller {
    var view: ProgressBarView {
        return _view
    }
    private weak var _view: ProgressBarView!
    private let disposeBag = DisposeBag()
    private let color: BehaviorSubject<UIColor> = BehaviorSubject(value: ColorStyles.getColor("pink4")!)
    private let maxValue: BehaviorSubject<Double>
    private let currentValue: BehaviorSubject<Double>
    // Observable of (oldValue, newValue)
    private lazy var progressValuePair = Observable.zip(self.progressValue, self.progressValue.skip(1))
    private lazy var progressValue = BehaviorSubject.combineLatest(currentValue, maxValue)
        .map { (curr, max) in
            return curr / max
        }

    init(usingXib xibView: XibView, currentValue: Double, maxValue: Double) {
        _view = xibView.getView()
        self.currentValue = BehaviorSubject(value: currentValue)
        self.maxValue = BehaviorSubject(value: maxValue)
    }

    convenience init(usingXib xibView: XibView) {
        self.init(usingXib: xibView, currentValue: 0, maxValue: 1)
    }

    convenience init(usingXib xibView: XibView, maxValue: Double) {
        self.init(usingXib: xibView, currentValue: 0, maxValue: maxValue)
    }

    func setColor(_ value: UIColor) {

    }

    func setCurrentValue(_ value: Double) {
        currentValue.onNext(value)
    }

    func setMaxValue(_ value: Double) {
        maxValue.onNext(value)
    }

    func configure() {
        createCircularPath()
        progressValuePair.subscribe { [weak self] event in
            guard let (oldValue, newValue) = event.element else {
                return
            }
            self?.setProgressValue(from: oldValue, to: newValue)
        }.disposed(by: disposeBag)
        color.distinctUntilChanged().subscribe { [weak self] event in
            guard let value = event.element else {
                return
            }
            self?.view.trackLayer.strokeColor = value.withAlphaComponent(0.4).cgColor
            self?.view.progressLayer.strokeColor = value.cgColor
        }.disposed(by: disposeBag)
    }

    private func createCircularPath() {
        let radius = view.frame.size.width / 2
        let lineWidth = view.frame.size.width / 10
        view.layer.cornerRadius = radius
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: radius, y: radius),
                                      radius: (view.frame.size.width - 1.5) / 2,
                                      startAngle: CGFloat(-0.5 * Double.pi),
                                      endAngle: CGFloat(1.5 * Double.pi),
                                      clockwise: true)
        let trackLayer = view.trackLayer
        trackLayer.path = circlePath.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineWidth = lineWidth
        trackLayer.strokeEnd = 1.0
        view.layer.addSublayer(trackLayer)

        let progressLayer = view.progressLayer
        progressLayer.path = circlePath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.strokeEnd = 0.0
        view.layer.addSublayer(progressLayer)
    }

    private func setProgressValue(from oldValue: Double, to rawNewValue: Double) {
        guard let maxBound = try? maxValue.value() else {
            return
        }
        let newValue = rawNewValue.clamp(from: 0.0, to: maxBound)
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 0.2

        animation.fromValue = oldValue
        animation.toValue = newValue
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName(rawValue: "linear"))
        view.progressLayer.strokeEnd = CGFloat(newValue)
        view.progressLayer.add(animation, forKey: "animateCircle")
    }
}
