//
//  UIFont+Helper.swift
//  Pods
//
//  Created by Jeroen Bakker on 27/12/2016.
//
//

import Foundation

public extension UIFont {
    
    public func printAvailableFonts() {
        UIFont.familyNames.forEach { (family) in
            print("\(family)")
            UIFont.fontNames(forFamilyName: family).forEach({ (name) in
                print("== \(name)")
            })
        }
    }
}
