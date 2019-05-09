//
//  Bool+Helper.swift
//  Pods
//
//  Created by Antoine van der Lee on 08/07/16.
//
//

import Foundation

public extension Bool {
    var stringValue: String {
        return self == true ? "true" : "false"
    }
}
