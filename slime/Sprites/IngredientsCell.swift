//
//  IngredientsCell.swift
//  slime
//
//  Created by Developer on 2/4/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class IngredientsCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    let imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
//        image.contentMode = .scaleAspectFill
//        image.clipsToBounds = true
//        image.layer.cornerRadius = 50
//        image.backgroundColor = UIColor.gray
        return image
    }()


//    let textLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.textAlignment = .center
//        label.textColor = .black
//        label.text = "New Person"
//        return label
//    }()


    func  setupView(){
        addSubview(imageView)
//        addSubview(textLabel)

        imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 60).isActive = true

//        textLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
//        textLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5).isActive = true
//        textLabel.heightAnchor.constraint(equalToConstant: 15).isActive = true
//        textLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
