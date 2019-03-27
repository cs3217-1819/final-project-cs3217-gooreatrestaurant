//
//  SlimeNumberPadController.swift
//  slime
//
//  Created by Gabriel Tan on 27/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class SlimeNumberPadController: Controller {
    let view: SlimeNumberPadView
    private var padControllers: [SlimeNumberInputController] = []
    private var responder: NumberPadResponder?
    private lazy var padViews: [XibView] = [
        view.buttonZero,
        view.buttonOne,
        view.buttonTwo,
        view.buttonThree,
        view.buttonFour,
        view.buttonFive,
        view.buttonSix,
        view.buttonSeven,
        view.buttonEight,
        view.buttonNine
    ]
    private lazy var backspaceButton: XibView = view.buttonBackspace
    private lazy var clearButton: XibView = view.buttonClear
    
    init(with view: UIView?) {
        guard let trueView = view as? SlimeNumberPadView else {
            Logger.it.log("Nib class is wrong")
            fatalError()
        }
        
        self.view = trueView
    }
    
    convenience init(withXib xibView: XibView) {
        self.init(with: xibView.contentView)
    }
    
    // The bound responder will receive inputs from this number pad
    func bindTo(_ responder: NumberPadResponder) {
        self.responder = responder
    }
    
    func configure() {
        for (idx, padView) in padViews.enumerated() {
            let num = idx
            let controller = SlimeNumberInputController(withXib: padView)
                .set(number: num)
                .set(color: .yellow)
                .onTap {
                    self.responder?.respondTo(num)
                }
            controller.configure()
            padControllers.append(controller)
        }
        
        let backspaceController = SlimeNumberInputController(withXib: backspaceButton)
            .set(text: "Backspace")
            .set(color: .green)
            .onTap {
                self.responder?.respondToBackspace()
            }
        backspaceController.configure()
        padControllers.append(backspaceController)
        
        let clearController = SlimeNumberInputController(withXib: clearButton)
            .set(text: "Clear")
            .set(color: .red)
            .onTap {
                self.responder?.respondToClear()
            }
        padControllers.append(clearController)
    }
}
