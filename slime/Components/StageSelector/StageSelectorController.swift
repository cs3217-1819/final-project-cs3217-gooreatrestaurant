//
//  StageSelectorController.swift
//  slime
//
//  Created by Gabriel Tan on 16/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit
import RxSwift

class StageSelectorController: Controller {
    let view: StageSelectorView
    var levels: [Level] = []
    var selectedLevelId = BehaviorSubject<String>(value: "")
    private var onSelectCallback: ((Level) -> ())?
    private var helper: StageSelectorHelper?
    
    init(withXib xibView: XibView) {
        view = xibView.getView()
    }
    
    init() {
        guard let trueView = UIView.initFromNib("StageSelectorView") as? StageSelectorView else {
            fatalError("Nib class is wrong")
        }
        view = trueView
    }
    
    func onSelect(_ callback: @escaping (Level) -> ()) {
        onSelectCallback = callback
    }
    
    func configure() {
        let helper = StageSelectorHelper(levels: levels, selectedLevelId: selectedLevelId, onSelect: onSelectCallback)
        view.collectionView.delegate = helper
        view.collectionView.dataSource = helper
        
        view.collectionView.reloadData()
        view.collectionView.flashScrollIndicators()
        self.helper = helper
    }
}

class StageSelectorHelper: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    private let disposeBag = DisposeBag()
    private var levels: [Level]
    private var controllers: [String: StagePreviewController] = [:]
    private var currentActiveId: String = ""
    private var onSelect: ((Level) -> ())?
    
    init(levels: [Level], selectedLevelId: BehaviorSubject<String>, onSelect: ((Level) -> ())?) {
        self.levels = levels
        self.onSelect = onSelect
        super.init()
        
        selectedLevelId.subscribe { event in
            guard let levelId = event.element else {
                return
            }
            
            if let previousActiveController = self.controllers[self.currentActiveId] {
                previousActiveController.view.layer.borderWidth = 0
            }
            
            self.currentActiveId = levelId
            
            if let controller = self.controllers[levelId] {
                controller.view.layer.borderWidth = 4
                controller.view.layer.borderColor = ColorStyles.getColor("pink3")?.cgColor
            }
        }.disposed(by: disposeBag)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelect?(levels[indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 180, height: collectionView.bounds.height * 0.9)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return levels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let level = levels[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "stagePreviewCell", for: indexPath) as! StageCellView
        cell.layoutIfNeeded()
        if let controller = controllers[level.id] {
            controller.setBackgroundName(name: "background-1")
            controller.setStageName(name: level.preview)
            controller.configure()
            cell.levelLabel.text = level.name
            
            if level.id == currentActiveId {
                controller.view.layer.borderWidth = 4
                controller.view.layer.borderColor = ColorStyles.getColor("pink3")?.cgColor
            }
            return cell
        }
        print(cell.bounds)
        print(cell.stagePreview.bounds)
        let controller = StagePreviewController(with: cell.stagePreview)
        controller.setBackgroundName(name: "background-1")
        controller.setStageName(name: level.preview)
        controller.configure()
        controllers[level.id] = controller
        if level.id == currentActiveId {
            controller.view.layer.borderWidth = 4
            controller.view.layer.borderColor = ColorStyles.getColor("pink3")?.cgColor
        }
        cell.levelLabel.text = level.name
        
        return cell
    }
}
