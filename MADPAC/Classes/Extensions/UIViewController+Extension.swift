//
//  UIViewController+Extension.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 29/05/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit

extension UIViewController {
    func debugLog(_ message: String) {
        let thisType = type(of: self)
        print("\(String(describing: thisType.self)): \(message)")
    }
    
    func getNavigationBarHeight() -> CGFloat {
        if #available(iOS 11.0, *) {
            let navbarHeight = navigationController?.navigationBar.frame.height ?? 0
            let safeAreaHeight = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
            let statusBarHeight = UIApplication.shared.statusBarFrame.height
            if safeAreaHeight <= 0 {
                return navbarHeight + statusBarHeight
            } else {
                return navbarHeight + safeAreaHeight
            }
        } else {
            let navbarHeight = navigationController?.navigationBar.frame.height ?? 0
            let statusBarHeight = UIApplication.shared.statusBarFrame.height
            return navbarHeight + statusBarHeight
        }
    }
    
    func getTabBarHeight(includingSafeArea: Bool = true) -> CGFloat {
        var height = tabBarController?.tabBar.frame.height ?? 0
        if #available(iOS 11.0, *), includingSafeArea {
            height += UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        }
        return height
    }
    
    func getSafeAreaInsets() -> UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.keyWindow?.safeAreaInsets ?? UIEdgeInsets.zero
        }
        return UIEdgeInsets.zero
    }
}

extension UIView {
    func debugLog(_ message: String) {
        let thisType = type(of: self)
        print("\(String(describing: thisType.self)): \(message)")
    }
}
