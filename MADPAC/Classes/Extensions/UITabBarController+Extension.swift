//
//  UITabBarController+Extension.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 21/07/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit

extension UITabBarController {
    func hideTabBar(animated: Bool) {
        guard let madSelf = self as? MADTabBarController, !madSelf.tabBarIsHidden, UserPreferences.autoHideTabBar else { return }
        if animated {
            madSelf.tabBarIsHidden = true
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [.curveEaseInOut, .allowUserInteraction], animations: { [weak self] in
                guard let `self` = self else { return }
                self.tabBar.transform = CGAffineTransform.identity.translatedBy(x: 0, y: self.tabBar.frame.height)
            }) { (completed) in
                madSelf.tabBarIsHidden = true
            }
        } else {
            tabBar.transform = CGAffineTransform.identity.translatedBy(x: 0, y: self.tabBar.frame.height)
            madSelf.tabBarIsHidden = true
        }
    }
    
    func showTabBar(animated: Bool) {
        guard let madSelf = self as? MADTabBarController, madSelf.tabBarIsHidden, UserPreferences.autoHideTabBar else { return }
        if animated {
            madSelf.tabBarIsHidden = false
            UIView.animate(withDuration: animated ? 0.7 : 0, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [.curveEaseInOut, .allowUserInteraction], animations: { [weak self] in
                guard let `self` = self else { return }
                self.tabBar.transform = CGAffineTransform.identity
            }) { (completed) in
                madSelf.tabBarIsHidden = false
            }
        } else {
            tabBar.transform = CGAffineTransform.identity
            madSelf.tabBarIsHidden = false
        }
    }
}
