//
//  StageSelectorController.swift
//  slime
//
//  Created by Gabriel Tan on 16/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class StageSelectorController: Controller {
    let view: StageSelectorView
    var levels: [Level] = []
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
        let helper = StageSelectorHelper(levels: levels, onSelect: onSelectCallback)
        view.collectionView.delegate = helper
        view.collectionView.dataSource = helper
        
        view.collectionView.reloadData()
        self.helper = helper
    }
}

class StageSelectorHelper: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    private var levels: [Level]
    private var controllers: [String: StagePreviewController] = [:]
    private var onSelect: ((Level) -> ())?
    init(levels: [Level], onSelect: ((Level) -> ())?) {
        self.levels = levels
        self.onSelect = onSelect
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelect?(levels[indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print(collectionView.bounds.height)
        return CGSize(width: 200, height: collectionView.bounds.height * 0.9)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return levels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("dequeueing cell")
        let level = levels[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "stagePreviewCell", for: indexPath) as! StageCellView
        
        if let controller = controllers[level.id] {
            controller.setBackgroundName(name: "background-1")
            controller.setStageName(name: level.preview)
            controller.configure()
            cell.levelLabel.text = level.name
            return cell
        }
        let controller = StagePreviewController(with: cell.stagePreview)
        controller.setBackgroundName(name: "background-1")
        controller.setStageName(name: level.preview)
        controller.configure()
        controllers[level.id] = controller
        cell.levelLabel.text = level.name
        
        return cell
    }
}
