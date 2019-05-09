//
//  UINavigationBar+Helper.swift
//
//  Created by Antoine van der Lee on 16/06/15.
//  Copyright (c) 2015 Triple IT. All rights reserved.
//

import UIKit

public extension UINavigationBar {
    
    func makeSolid() {
        setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        shadowImage = UIImage()
    }
    
    /// Hides the title in the navigation bar
    func hideTitle() {
        titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.clear]
    }
}
