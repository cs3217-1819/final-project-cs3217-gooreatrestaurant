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
            .takeWhile { x in
                x <= self.text.count
            }
            .subscribe { [weak self] event in
                guard let this = self else {
                    return
                }
                guard let index = event.element else {
                    return
                }
                if index > this.text.count {
                    return
                }
                this.dialogText.onNext(String(this.text[0..<index]))
            }.disposed(by: disposeBag)
    }
    
    func startAnimation(duration: Double) {
        // Find out how long each character should take
        let charDuration = duration / Double(text.count)
        startAnimation(durationPerCharacter: charDuration)
    }
    
    
    private func setupReactive() {
        dialogText.distinctUntilChanged().subscribe { [weak self] event in
            guard let text = event.element else {
                return
            }
            self?.setNewText(text)
        }.disposed(by: disposeBag)
    }
    
    private func setNewText(_ text: String) {
        view.dialogLabel.text = text
    }
}
