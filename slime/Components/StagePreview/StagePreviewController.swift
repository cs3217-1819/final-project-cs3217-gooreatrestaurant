//
//  StagePreviewController.swift
//  slime
//
//  Created by Gabriel Tan on 16/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import RxSwift

class StagePreviewController: Controller {
    let view: UIView
    private let backgroundView: UIView
    private let backgroundImageView: UIImageView
    private let stageImageView: UIImageView
    
    private let disposeBag = DisposeBag()
    
    private let backgroundImageName: BehaviorSubject<String> = BehaviorSubject(value: "")
    private let stageImageName: BehaviorSubject<String> = BehaviorSubject(value: "")
    
    init(with view: UIView) {
        self.view = view
        
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        
        backgroundView = UIView(frame: view.bounds.scaleY(by: 2))
        backgroundImageView = UIImageView(frame: backgroundView.bounds)
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundView.addSubview(backgroundImageView)
        
        stageImageView = UIImageView(frame: backgroundView.frame)
        stageImageView.contentMode = .scaleAspectFit
        backgroundView.addSubview(stageImageView)
        
        view.addSubview(backgroundView)
    }
    
    func configure() {
        backgroundView.frame = backgroundView.frame.offsetBy(dx: 0, dy: -view.frame.height)
        
        UIView.animate(withDuration: 5.0, delay: 0.0, options: [.repeat, .autoreverse], animations: {
            self.backgroundView.frame = self.backgroundView.frame.offsetBy(dx: 0,
                                                                           dy: self.view.frame.height)
        }, completion: nil)
        
        view.addSubview(backgroundView)
        view.clipsToBounds = true
        
        setupReactive()
    }
    
    func setBackgroundName(name: String) {
        backgroundImageName.onNext(name)
    }
    
    func setStageName(name: String) {
        stageImageName.onNext(name)
    }
    
    private func setupReactive() {
        backgroundImageName.distinctUntilChanged().subscribe { event in
            guard let imageName = event.element else {
                return
            }
            
            let backgroundImage = ImageProvider.get(imageName)
            self.backgroundImageView.image = backgroundImage
        }.disposed(by: disposeBag)
        
        stageImageName.distinctUntilChanged().subscribe { event in
            guard let imageName = event.element else {
                return
            }
            
            let stageImage = ImageProvider.get(imageName)
            self.stageImageView.image = stageImage
        }.disposed(by: disposeBag)
    }
}
