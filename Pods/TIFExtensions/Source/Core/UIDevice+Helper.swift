//
//  UIDevice+Helper.swift
//  MyVodafone
//
//  Created by Tom van der Spek on 13/04/16.
//  Copyright © 2016 Triple IT. All rights reserved.
//

import Foundation

public extension UIDevice {
    
    static var isPad: Bool {
        return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
    }
    
    static var isPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone
    }
}
