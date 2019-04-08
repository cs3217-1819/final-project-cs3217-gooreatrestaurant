//
//  Cosmetics.swift
//  slime
//
//  Created by Gabriel Tan on 8/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import RxSwift

struct Cosmetic {
    var name: String
    var image: UIImage?
    
    init(_ name: String, _ image: UIImage?) {
        self.name = name
        self.image = image
    }
}

class Wardrobe {
    private let disposeBag = DisposeBag()
    var activeCosmetic: Observable<Cosmetic>
    var activeIndex: BehaviorSubject<Int>
    var cosmetics: [Cosmetic]
    private var buttonControllers: [AnyObject] = []
    private var indexDict: [String: Int] = [:]
    
    var selected: Cosmetic? {
        guard let index = try? activeIndex.value() else {
            return nil
        }
        return cosmetics[index]
    }
    
    init(withActiveCosmetic cosmetic: String, cosmetics: [Cosmetic]) {
        self.cosmetics = cosmetics
        for (i, cos) in cosmetics.enumerated() {
            indexDict[cos.name] = i
        }
        
        guard let initialCosmetic = indexDict[cosmetic] else {
            fatalError()
        }
        
        activeIndex = BehaviorSubject(value: initialCosmetic)
        activeCosmetic = activeIndex.distinctUntilChanged().map { index in
            return cosmetics[index]
        }
    }
    
    func setActiveCosmetic(_ name: String) {
        guard let cosmeticIndex = indexDict[name] else {
            return
        }
        
        activeIndex.onNext(cosmeticIndex)
    }
    
    func bindTo(_ controllers: [ItemBoxController]) {
        let count = cosmetics.count
        for (i, controller) in controllers.enumerated() {
            if i >= count {
                continue
            }
            controller.setCosmetic(cosmetics[i])
            controller.view.rx.gesture(.tap())
                .when(.recognized)
                .subscribe { _ in
                    self.activeIndex.onNext(i)
                }.disposed(by: disposeBag)
        }
        
        activeIndex.subscribe { event in
            guard let index = event.element else {
                return
            }
            
            for (i, controller) in controllers.enumerated() {
                if i == index {
                    controller.active = true
                } else {
                    controller.active = false
                }
            }
        }.disposed(by: disposeBag)
    }
}

enum CosmeticConstants {
    static let hatsDict: [String: Cosmetic] = CosmeticConstants.hatsList
        .reduce(into: [String: Cosmetic](), { dict, entry in
            dict[entry.name] = entry
        })
    static let accessoriesDict: [String: Cosmetic] = CosmeticConstants.accessoriesList
        .reduce(into: [String: Cosmetic](), { dict, entry in
            dict[entry.name] = entry
        })
    static let hatsList = [
        Cosmetic("none", ImageProvider.get("level-dot")),
        Cosmetic("Hat 1", ImageProvider.get("crown")),
        Cosmetic("Hat 2", ImageProvider.get("table"))
    ]
    
    static let accessoriesList = [
        Cosmetic("none", ImageProvider.get("level-dot")),
        Cosmetic("Apple", ImageProvider.get("SlicedApple"))
    ]
    
    static func getHats() -> Wardrobe {
        return Wardrobe(withActiveCosmetic: "none",
                        cosmetics: CosmeticConstants.hatsList)
    }
    
    static func getAccessories() -> Wardrobe {
        return Wardrobe(withActiveCosmetic: "none",
                        cosmetics: CosmeticConstants.accessoriesList)
    }
}
