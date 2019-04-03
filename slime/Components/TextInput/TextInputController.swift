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
    private let disposeBag = DisposeBag()
    // Used when shifting the view back to its original space
    private var modalController: TextInputController?
    private var isRoot = true
    let label = BehaviorSubject(value: "")
    let view: TextInputView
    let context: Context
    var value: String? {
        get {
            return view.inputField.text
        }
        set {
            view.inputField.text = newValue
        }
    }
    private var floatingView: UIView?
    
    
    init(usingXib xibView: XibView, context: Context) {
        guard let trueView = xibView.contentView as? TextInputView else {
            Logger.it.error("Nib class is wrong")
            fatalError()
        }
        view = trueView
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
        if isRoot {
            setupKeyboardListeners()
        }
    }
    
    private func set(label: String) {
        view.labelLabel.text = label
    }
    
    private func setupKeyboardListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(avoidKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopAvoidingKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func avoidKeyboard(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardFrame = keyboardSize.cgRectValue
        let inputFrame = CGRect.zero
        floatingView = UIView(frame: inputFrame)
        guard let parent = floatingView else {
            return
        }
        modalController = TextInputController(parent: parent, context: context)
        modalController?.isRoot = false
        modalController?.configure()
        modalController?.value = value
        
        context.showView(view: parent)
        parent.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(self.view.frame.width)
            make.height.equalTo(self.view.frame.height)
            make.bottom.equalToSuperview().offset(-keyboardFrame.height)
            make.top.lessThanOrEqualToSuperview()
        }
        parent.layoutIfNeeded()
        modalController?.view.inputField.becomeFirstResponder()
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
    
    private func setupReactive() {
        label.distinctUntilChanged().subscribe { event in
            guard let value = event.element else {
                return
            }
            self.set(label: value)
        }.disposed(by: disposeBag)
    }
    
    deinit {
        Logger.it.info("TextInputController deinit")
    }
}
