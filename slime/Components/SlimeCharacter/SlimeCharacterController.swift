//
//  SlimeCharacterController.swift
//  slime
//
//  Created by Gabriel Tan on 9/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import RxSwift

class SlimeCharacterController: Controller {
    private let disposeBag = DisposeBag()
    let view: SlimeCharacterView
    
    init(withXib xibView: XibView) {
        view = xibView.getView()
    }
    
    func bindTo(player: BehaviorSubject<Player?>) {
        player.subscribe { event in
            guard let optChar = event.element else {
                return
            }
            guard let char = optChar else {
                return
            }
            
            self.configureForCharacter(player: char)
        }.disposed(by: disposeBag)
        
        guard let unwrappedPlayer = try? player.value() else {
            return
        }
        guard let truePlayer = unwrappedPlayer else {
            return
        }
        configureForCharacter(player: truePlayer)
    }
    
    func bindTo(_ character: BehaviorSubject<UserCharacter>) {
        character.subscribe { event in
            guard let char = event.element else {
                return
            }
            
            self.configureForCharacter(char)
        }.disposed(by: disposeBag)
        guard let unwrappedCharacter = try? character.value() else {
            return
        }
        configureForCharacter(unwrappedCharacter)
    }
    
    func configure() {
        
    }
    
    private func configureForCharacter(player: Player) {
        configureColor(player.color)
        configureHat(player.hat)
        configureAccessory(player.accessory)
    }
    
    private func configureForCharacter(_ char: UserCharacter) {
        configureColor(char.color)
        configureHat(char.hat)
        configureAccessory(char.accessory)
    }
    
    private func configureColor(_ color: SlimeColor) {
        view.slimeImageView.image = color.getImage()
    }
    
    private func configureHat(_ hat: String) {
        guard let hatCosmetic = CosmeticConstants.hatsDict[hat] else {
            return
        }
        
        view.hatImageView.image = hatCosmetic.image
    }
    
    private func configureAccessory(_ accessory: String) {
        guard let accCosmetic = CosmeticConstants.accessoriesDict[accessory] else {
            return
        }
        
        view.accessoryImageView.image = accCosmetic.image
    }
}
