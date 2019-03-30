//
//  Context.swift
//  slime
//
//  Created by Gabriel Tan on 18/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import RxSwift

class Context {
    private let disposeBag = DisposeBag()
    let router = Router(with: .TitleScreen)
    let db: GameDatabase = GameDB()
    private var baseView: UIView {
        return mainController.view
    }
    private(set) var userCharacter: BehaviorSubject<UserCharacter>?
    private let mainController: MainController
    private let modal = ModalController()
    
    init(using viewController: MainController) {
        self.mainController = viewController
        loadUserData()
    }
    
    private func saveCharacter() {
        guard let optCharacter = try? userCharacter?.value() else {
            return
        }
        guard let character = optCharacter else {
            return
        }
        LocalData.it.saveCharacter(character)
    }
    
    func loadUserData() {
        guard let character = LocalData.it.getUserCharacter() else {
            return
        }
        guard let trueCharacter = userCharacter else {
            userCharacter = BehaviorSubject(value: character)
            setupAutosaveCharacter()
            return
        }
        trueCharacter.onNext(character)
    }
    
    func gainCharacterExp(_ exp: Int) {
        guard let optChar = try? userCharacter?.value() else {
            return
        }
        guard let char = optChar else {
            return
        }
        char.gainExp(exp)
        userCharacter?.onNext(char)
    }
    
    func showModal(view: UIView, frame: CGRect) {
        modal.setContent(view)
        modal.configure()
        modal.open(with: baseView, frame: frame, closeOnOutsideTap: true)
    }
    
    func showModal(view: UIView, closeOnOutsideTap: Bool) {
        modal.setContent(view)
        modal.configure()
        modal.open(with: baseView, closeOnOutsideTap: closeOnOutsideTap)
    }
    
    func showModal(view: UIView) {
        showModal(view: view, closeOnOutsideTap: true)
    }
    
    func closeModal() {
        modal.close()
    }
    
    func createAlert() -> AlertController {
        return AlertController(using: modal)
    }
    
    func presentAlert(_ alert: AlertController) {
        alert.configure()
        modal.configure()
        modal.open(with: baseView, closeOnOutsideTap: false)
    }
    
    func presentUnimportantAlert(_ alert: AlertController) {
        alert.configure()
        modal.configure()
        modal.open(with: baseView, closeOnOutsideTap: true)
    }
    
    func closeAlert() {
        modal.close()
    }
    
    func routeTo(_ route: Route) {
        let previousRoute = router.currentRoute
        let previousVC = router.currentViewController
        router.routeTo(route)
        mainController.performSegue(from: previousVC,
                                    to: router.currentViewController,
                                    coordsDiff: router.currentRoute.coordinates - previousRoute.coordinates)
    }
    
    func routeToAndPrepareFor<Control: ViewControllerProtocol>(_ route: Route) -> Control {
        routeTo(route)
        return router.currentViewController as! Control
    }
    
    func segueToGame() {
        mainController.performSegue(withIdentifier: "toGame", sender: nil)
    }
    
    private func setupAutosaveCharacter() {
        userCharacter?.subscribe { event in
            guard let player = event.element else {
                return
            }
            
            LocalData.it.saveCharacter(player)
        }.disposed(by: disposeBag)
    }
}
