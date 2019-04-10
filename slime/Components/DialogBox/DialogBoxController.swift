//
//  DialogBoxController.swift
//  slime
//
//  Created by Gabriel Tan on 10/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import RxSwift

class DialogBoxController: Controller {
    private let disposeBag = DisposeBag()
    private let dialogText = BehaviorSubject(value: "")
    let view: DialogBoxView
    var text: String = ""
    
    init(withXib xibView: XibView) {
        view = xibView.getView()
    }
    
    init(with view: UIView) {
        self.view = view as! DialogBoxView
    }
    
    func configure() {
        setupReactive()
    }
    
    func setColor(_ colorCode: String) {
        view.backgroundView.background = colorCode
    }
    
    func startAnimation(durationPerCharacter: Double) {
        // Find out how long each character should take
        Observable<Int>
            .interval(durationPerCharacter, scheduler: MainScheduler.instance)
            .subscribe { event in
                guard let index = event.element else {
                    return
                }
                if index > self.text.count {
                    return
                }
                self.dialogText.onNext(String(self.text[0..<index]))
            }.disposed(by: disposeBag)
    }
    
    func startAnimation(duration: Double) {
        // Find out how long each character should take
        let charDuration = duration / Double(text.count)
        Observable<Int>
            .interval(charDuration, scheduler: MainScheduler.instance)
            .subscribe { event in
                guard let index = event.element else {
                    return
                }
                if index > self.text.count {
                    return
                }
                self.dialogText.onNext(String(self.text[0..<index]))
            }.disposed(by: disposeBag)
    }
    
    
    private func setupReactive() {
        dialogText.distinctUntilChanged().subscribe { event in
            guard let text = event.element else {
                return
            }
            self.setNewText(text)
        }.disposed(by: disposeBag)
    }
    
    private func setNewText(_ text: String) {
        view.dialogLabel.text = text
    }
}
