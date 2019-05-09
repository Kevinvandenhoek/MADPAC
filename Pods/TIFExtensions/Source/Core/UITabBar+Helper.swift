//
//  UITabBar+Helper.swift
//
//  Created by Antoine van der Lee on 16/06/15.
//  Copyright (c) 2015 Triple IT. All rights reserved.
//

import UIKit

public extension UITabBar {
    
    /// Hides the titles in the tab bar
    func hideTitles(){
        self.items?.forEach({ (tbi) in
            tbi.title = ""
            tbi.titlePositionAdjustment = UIOffsetMake(0, 50) // Hide title
            tbi.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
        })
    }
    
    func makeSolid(){
        self.shadowImage = UIImage()
    }
}
