//
//  UIImage+Helper.swift
//  MyVodafone
//
//  Created by Tom van der Spek on 13/04/16.
//  Copyright © 2016 Triple IT. All rights reserved.
//


import UIKit

public extension UIImage {
    
    static func imageWith(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        defer {
            UIGraphicsEndImageContext()
        }
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        guard let image: UIImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return UIImage()
        }
        
        return image
    }
}
