//
//  TutorialScreenController.swift
//  slime
//
//  Created by Gabriel Tan on 12/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import RxSwift

class TutorialScreenController: Controller {
    let view: TutorialScreenView
    private let disposeBag = DisposeBag()
    private var tutorialSteps: [Tutorial] = []
    private var currentTutorialIndex: BehaviorSubject<Int>!
    private var callback: (() -> ())?
    
    init(withXib xibView: XibView) {
        view = xibView.getView()
    }
    
    func configure() {
        setupReactive()
    }
    
    // For DI use, will crash if this method is not called with a non-empty tutorial array.
    func use(tutorialSteps: [Tutorial]) {
        guard !tutorialSteps.isEmpty else {
            // Empty tutorial steps, ignore
            return
        }
        self.tutorialSteps = tutorialSteps
        currentTutorialIndex = BehaviorSubject(value: 0)
    }
    
    func onDone(callback: @escaping () -> ()) {
        self.callback = callback
    }
    
    private func setupReactive() {
        let count = tutorialSteps.count
        currentTutorialIndex.scan(0, accumulator: { $0 + $1 }).subscribe { event in
            guard let tutorialIndex = event.element else {
                return
            }
            
            if tutorialIndex == count {
                // Go to next screen
                self.callback?()
                return
            } else if tutorialIndex > count {
                return
            }
            
            self.setView(tutorial: self.tutorialSteps[tutorialIndex])
        }.disposed(by: disposeBag)
        
        view.rx.gesture(.tap())
            .when(.recognized)
            .subscribe { _ in
                self.currentTutorialIndex.onNext(1)
            }.disposed(by: disposeBag)
    }
    
    private func setView(tutorial: Tutorial) {
        view.tutorialImageView.image = tutorial.image
        view.titleLabel.text = tutorial.title
        view.descriptionLabel.text = tutorial.description
    }
}
