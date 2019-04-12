//
//  TextInputController.swift
//  slime
//
//  Created by Gabriel Tan on 30/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import RxSwift

class TextInputController: Controller {
    var view: TextInputView {
        return inputController.view
    }
    var value: String? {
        return inputController.value
    }
    var label: String {
        get {
            return try! inputController.label.value()
        }
        set {
            inputController.label.onNext(newValue)
        }
    }

    private let disposeBag = DisposeBag()
    private var modalController: InputController?
    private let inputController: InputController
    private let context: Context
    private var floatingView: UIView?

    private class InputController: Controller {
        let view: TextInputView
        private let context: Context
        private let disposeBag = DisposeBag()
        private(set) var label = BehaviorSubject(value: "")
        var value: String? {
            get {
                return view.inputField.text
            }
            set {
                view.inputField.text = newValue
            }
        }

        init(usingXib xibView: XibView, context: Context) {
            view = xibView.getView()
            self.context = context
        }

        init(parent: UIView, context: Context) {
            guard let trueView = UIView.initFromNib("TextInputView") as? TextInputView else {
                Logger.it.error("Nib class is wrong")
                fatalError()
            }
            view = trueView
            self.context = context
            parent.addSubview(view)
            view.constraintToParent()
        }

        func configure() {
            setupReactive()
        }
        
        private func set(label: String) {
            view.labelLabel.text = label
        }

        private func setupReactive() {
            label.distinctUntilChanged().subscribe { event in
                guard let value = event.element else {
                    return
                }
                self.set(label: value)
            }.disposed(by: disposeBag)
        }
    }

    init(usingXib xibView: XibView, context: Context) {
        inputController = InputController(usingXib: xibView, context: context)
        self.context = context
    }

    init(parent: UIView, context: Context) {
        inputController = InputController(parent: parent, context: context)
        self.context = context
    }

    func configure() {
        setupKeyboardListeners()
        inputController.configure()
    }

    private func setupKeyboardListeners() {
        view.rx.gesture(.tap())
            .when(.ended)
            .subscribe { _ in
                self.openKeyboardModal()
                self.modalController?.view.inputField.becomeFirstResponder()
            }.disposed(by: disposeBag)
        KeyboardService.listenToKeyboardSize { size in
            guard let parent = self.floatingView else {
                return
            }
            parent.snp.updateConstraints { make in
                make.bottom.equalToSuperview().offset(-size.height)
            }
        }.disposed(by: disposeBag)
        NotificationCenter.default.addObserver(self, selector: #selector(stopAvoidingKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func openKeyboardModal() {
        floatingView = UIView(frame: CGRect.zero)
        guard let parent = floatingView else {
            return
        }
        let childInputController = InputController(parent: parent, context: context)
        childInputController.configure()
        childInputController.value = value
        childInputController.label.onNext(label)

        modalController = childInputController
        context.modal.showView(view: parent)
        let keyboardHeight = KeyboardService.keyboardHeight()
        parent.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(self.view.frame.width)
            make.height.equalTo(self.view.frame.height)
            make.bottom.equalToSuperview().offset(-keyboardHeight)
        }
        // Async block needed for UI event to properly update
        DispatchQueue.main.async {
            parent.layoutIfNeeded()
            childInputController.view.inputField.becomeFirstResponder()
        }

    }

    private func removeFloatingView() {
        guard let parent = floatingView else {
            return
        }
        parent.removeFromSuperview()
        modalController?.view.removeFromSuperview()
        view.inputField.text = modalController?.value
        modalController = nil
        floatingView = nil
    }

    @objc private func stopAvoidingKeyboard(notification: NSNotification) {
        guard let parent = floatingView else {
            return
        }
        parent.removeFromSuperview()
        modalController?.view.removeFromSuperview()
        view.inputField.text = modalController?.value
        modalController = nil
        floatingView = nil
    }
}
