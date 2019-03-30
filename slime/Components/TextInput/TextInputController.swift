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
    let label = BehaviorSubject(value: "")
    let view: TextInputView
    let context: Context
    var value: String? {
        return view.inputField.text
    }
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
    }
    
    func configure() {
        setupReactive()
        setupKeyboardListeners()
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
        let inputFrame = CGRect(x: keyboardFrame.minX, y: keyboardFrame.maxY + view.frame.height, width: view.frame.width, height: view.frame.height)
        modalController = TextInputController(parent: UIView(frame: inputFrame), context: context)
        modalController?.configure()
        
        context.showModal(view: modalController!.view, closeOnOutsideTap: false)
        modalController?.view.inputField.becomeFirstResponder()
    }
    
    @objc private func stopAvoidingKeyboard() {
        context.closeModal()
        view.inputField.text = modalController?.value
        modalController = nil
        print("stop avoiding")
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
