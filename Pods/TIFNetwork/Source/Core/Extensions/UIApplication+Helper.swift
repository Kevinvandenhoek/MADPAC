//
//  UIApplication+Helper.swift
//  Pods
//
//  Created by Jeroen Bakker on 23/12/2016.
//
//

import Foundation

#if os(iOS)
extension UIApplication {
    
    // Used by Watch apps that do not have a UIApplication class
    class var sharedValue: UIApplication? {
        let selector = NSSelectorFromString("sharedApplication")
        guard responds(to: selector) else { return nil }
        return perform(selector).takeUnretainedValue() as? UIApplication
    }
}
#endif
