//
//  CustomizationMainViewController.swift
//  slime
//
//  Created by Gabriel Tan on 7/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import RxSwift

class CustomizationMainViewController: ViewController<CustomizationMainView>, CustomizationController {
    private let disposeBag = DisposeBag()
    private var levelProgressController: ProgressBarController?
    private var routeSubject: BehaviorSubject<CharacterCustomizationViewController.CustomizationRoute>!
    
    override func configureSubviews() {
        levelProgressController = ProgressBarController(usingXib: view.levelProgressView, maxValue: 100)
        levelProgressController?.configure()
        setupReactive()
    }
    
    func use(routeSubject: BehaviorSubject<CharacterCustomizationViewController.CustomizationRoute>) {
        self.routeSubject = routeSubject
    }
    
    private func setupReactive() {
        view.rx.gesture(.tap())
            .when(.recognized)
            .subscribe { _ in
                print("routing inner")
                self.routeSubject.onNext(.Main)
            }.disposed(by: disposeBag)
        context.data.userCharacter?.subscribe { event in
            guard let character = event.element else {
                return
            }
            
            self.refreshView(character)
        }.disposed(by: disposeBag)
        
        
    }
    
    private func refreshView(_ character: UserCharacter) {
        levelProgressController?.setCurrentValue(Double(character.exp))
        view.levelLabel.text = "\(character.level)"
        view.nameLabel.text = "\(character.name)"
    }
}
