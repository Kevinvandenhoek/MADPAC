//
//  UIImage+Extension.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 30/05/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import Nuke

extension UIImageView {
    
    func setImage(with url: String?) {
        guard let urlString = url, let url = URL(string: urlString) else { return }
        Nuke.loadImage(with: url, into: self)
    }
}
