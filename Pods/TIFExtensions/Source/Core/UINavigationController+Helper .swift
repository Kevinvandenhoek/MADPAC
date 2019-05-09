//
//  UINavigationController+Helper.swift
//  MyVodafone
//
//  Created by Tom van der Spek on 13/04/16.
//  Copyright © 2016 Triple IT. All rights reserved.
//

import UIKit

public extension UINavigationController {
    
    func popToViewControllerOfType(type: AnyClass, animated: Bool) -> Bool {
        if let viewController = viewControllers.first(where: { $0.isKind(of: type) }) {
            popToViewController(viewController, animated: animated)
            return true
        }
        return false
    }
}

