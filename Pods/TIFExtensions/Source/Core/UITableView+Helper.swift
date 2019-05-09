//
//  UITableView+Helper.swift
//  Pods
//
//  Created by Antoine van der Lee on 14/01/16.
//
//

import Foundation

public extension UITableViewCell {
    
    /// Returns string of class name
    static var reuseIdentifierValue: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
}
