//
//  ImageProvider.swift
//  slime
//
//  Created by Gabriel Tan on 13/3/19.
//  Copyright © 2019 nus.cs3217.a0166733y. All rights reserved.
//

import UIKit

class ImageProvider {
    private(set) static var instance: ImageProvider = ImageProvider()

    private var cache: [String: UIImage] = [:]

    private init() {

    }

    static func get(_ imageName: String) -> UIImage? {
        if let image = instance.cache[imageName] {
            return image
        }
        guard let image = UIImage(named: imageName) else {
            return nil
        }
        instance.cache[imageName] = image

        return image
    }
}
