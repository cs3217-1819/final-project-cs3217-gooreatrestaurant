//
//  CodeInputController.swift
//  slime
//
//  Created by Gabriel Tan on 27/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import RxSwift

class CodeInputController: Controller, NumberPadResponder {
    private let disposeBag = DisposeBag()
    let view: CodeInputView
    let inputCode: BehaviorSubject<[Int]> = BehaviorSubject(value: [])
    private lazy var codeViews: [TextLabel] = [
        view.inputOne,
        view.inputTwo,
        view.inputThree,
        view.inputFour,
        view.inputFive,
        view.inputSix
    ]
    
    init(with view: UIView?) {
        guard let trueView = view as? CodeInputView else {
            Logger.it.error("Nib class is wrong")
            fatalError()
        }
        self.view = trueView
    }
    
    convenience init(withXib xibView: XibView) {
        self.init(with: xibView.contentView)
    }
    
    func configure() {
        setupReactive()
    }
    
    func bindTo(numberPad: SlimeNumberPadController) {
        numberPad.bindTo(self)
    }
    
    func onComplete(_ callback: @escaping (String) -> ()) {
        inputCode.distinctUntilChanged()
            .filter { element in
                return element.count == 6
            }
            .map { element in
                return element.map { num in
                    return "\(num)"
                }
            }
            .subscribe { event in
                guard let code = event.element else {
                    return
                }
                callback(code.joined())
            }.disposed(by: disposeBag)
    }
    
    func respondTo(_ input: Int) {
        try? inputCode.onNext(inputCode.value() + [input])
    }
    
    func respondToBackspace() {
        guard var nextInput = try? inputCode.value() else {
            return
        }
        guard nextInput.last != nil else {
            return
        }
        nextInput.removeLast()
        inputCode.onNext(nextInput)
    }
    
    func respondToClear() {
        inputCode.onNext([])
    }
    
    private func setupReactive() {
        inputCode.distinctUntilChanged()
            .filter { element in
                return element.count <= 6
            }
            .subscribe { event in
            guard let code = event.element else {
                return
            }
            self.showCode(code)
        }.disposed(by: disposeBag)
    }
    
    private func showCode(_ code: [Int]) {
        let codeLength = code.count
        for i in 0..<codeViews.count {
            if i >= codeLength {
                codeViews[i].text = "-"
            } else {
                codeViews[i].text = "\(code[i])"
            }
        }
    }
}
