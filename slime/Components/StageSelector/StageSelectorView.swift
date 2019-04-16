//
//  StageSelectorView.swift
//  slime
//
//  Created by Gabriel Tan on 16/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class StageSelectorView: UIView {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionViewFlowLayout: UICollectionViewFlowLayout!
    override func awakeFromNib() {
        let nib = UINib(nibName: "StageCellView", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "stagePreviewCell")
    }
}
