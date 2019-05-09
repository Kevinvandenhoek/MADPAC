//
//  NSURL+Helper.swift
//  Pods
//
//  Created by Antoine van der Lee on 08/07/16.
//
//

import Foundation

public extension URL {
    var URLRequestValue: URLRequest {
        return URLRequest(url: self)
    }
    
    @available(*, deprecated, message: "Please use the struct type URLRequest")
    var mutableURLRequestValue: URLRequest {
        return self.URLRequestValue
    }
}
