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
        setupButtons()
    }

    func use(routeSubject: BehaviorSubject<CharacterCustomizationViewController.CustomizationRoute>) {
        self.routeSubject = routeSubject
    }
    
    private func setupButtons() {
        view.hatButton.rx.gesture(.tap())
            .when(.recognized)
            .subscribe { _ in
                self.routeSubject.onNext(.Hats)
            }.disposed(by: disposeBag)
        view.accessoryButton.rx.gesture(.tap())
            .when(.recognized)
            .subscribe { _ in
                self.routeSubject.onNext(.Accessories)
            }.disposed(by: disposeBag)
        view.baseButton.rx.gesture(.tap())
            .when(.recognized)
            .subscribe { _ in
                self.routeSubject.onNext(.Base)
            }.disposed(by: disposeBag)
    }

    private func setupReactive() {
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
        if let hat = CosmeticConstants.hatsDict[character.hat] {
            view.hatImageView.image = hat.image
        }
        if let accessory = CosmeticConstants.accessoriesDict[character.accessory] {
            view.accessoryImageView.image = accessory.image
        }
        view.baseImageView.image = character.color.getImage()
    }
}
