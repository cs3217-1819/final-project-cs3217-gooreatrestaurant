//
//  LevelDetailsBoxController.swift
//  slime
//
//  Created by Gabriel Tan on 15/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class LevelDetailsBoxController {
    let view: LevelDetailsBox
    
    init(using view: UIView) {
        guard let trueView = view as? LevelDetailsBox else {
            fatalError("View type is incorrect")
        }
        self.view = trueView
    }
    
    init(using xibView: XibView) {
        guard let trueView = xibView.contentView as? LevelDetailsBox else {
            fatalError("View type is incorrect")
        }
        self.view = trueView
    }
    
    func configure() {
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
    }
    
    func set(id: String) -> LevelDetailsBoxController {
        view.levelId.text = id
        return self
    }
    
    func set(name: String) -> LevelDetailsBoxController {
        view.levelName.text = name
        return self
    }
    
    func set(bestScore: Int) -> LevelDetailsBoxController {
        view.bestScore.text = "\(bestScore)"
        return self
    }
}
