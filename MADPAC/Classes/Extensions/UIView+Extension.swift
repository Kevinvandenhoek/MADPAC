//
//  UIView+Extension.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 29/10/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    func setShadow(radius: CGFloat, opacity: Float, offset: CGSize, color: UIColor = UIColor.black) {
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
    }
}
