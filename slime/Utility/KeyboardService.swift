//
//  KeyboardService.swift
//  slime
//
//  Created by Gabriel Tan on 3/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import RxSwift

/**
 * Utility class to find out the size of the keyboard
 * Source: https://stackoverflow.com/questions/26981261/get-height-of-ios-keyboard-without-displaying-keyboard
 */
class KeyboardService: NSObject {
    private let disposeBag = DisposeBag()
    static let it = KeyboardService()
    private var measuredSize: BehaviorSubject<CGRect> = BehaviorSubject(value: CGRect.zero)
    
    static func keyboardHeight() -> CGFloat {
        let keyboardSize = KeyboardService.keyboardSize()
        return keyboardSize.size.height
    }
    
    static func keyboardSize() -> CGRect {
        guard let value = try? it.measuredSize.value() else {
            return CGRect.zero
        }
        return value
    }
    
    static func listenToKeyboardSize(_ callback: @escaping (CGRect) -> ()) -> Disposable {
        return it.measuredSize.subscribe { event in
            guard let size = event.element else {
                return
            }
            callback(size)
        }
    }
    
    private func observeKeyboardNotifications() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(self.keyboardChange), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    @objc private func keyboardChange(_ notification: Notification) {
        guard let info = notification.userInfo else {
            return
        }
        guard let value = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        measuredSize.onNext(value.cgRectValue)
    }
    
    override init() {
        super.init()
        observeKeyboardNotifications()
        Logger.it.info("KeyboardService initialized")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
