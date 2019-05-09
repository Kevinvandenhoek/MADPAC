//
//  TIFAPIMethod.swift
//  Pods
//
//  Created by Antoine van der Lee on 30/11/15.
//
//

import Foundation
import Moya

public struct APIMethod : Equatable {
    public let path: String
    public let method: Moya.Method
    public let defaultParameters: [String: Any]?
    
    public init(path: String, method: Moya.Method, defaultParameters: [String:Any] = [:]) {
        self.path = path
        self.method = method
        self.defaultParameters = defaultParameters
    }
}

public func ==(lhs: APIMethod, rhs: APIMethod) -> Bool {
    return lhs.path == rhs.path && lhs.method == rhs.method
}
