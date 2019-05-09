//
//  UIWindow+Helper.swift
//
//  Created by Antoine van der Lee on 05/08/15.
//  Copyright (c) 2015 Triple IT. All rights reserved.
//

import Foundation

public extension UIWindow {
    
    func visibleViewController() -> UIViewController? {
        if let rootViewController: UIViewController = self.rootViewController {
            return UIWindow.getVisibleViewControllerFrom(viewController: rootViewController)
        }
        return nil
    }
    
    class func getVisibleViewControllerFrom(viewController vc:UIViewController?) -> UIViewController? {
        if vc == nil {
            return nil
        }
        
        if let navigationController = vc as? UINavigationController {
            return UIWindow.getVisibleViewControllerFrom(viewController: navigationController.visibleViewController)
        } else if let tabBarController = vc as? UITabBarController {
            return UIWindow.getVisibleViewControllerFrom(viewController: tabBarController.selectedViewController)
        } else {
            if let presentedViewController = vc?.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(viewController: presentedViewController)
            } else {
                return vc
            }
        }
    }
}
