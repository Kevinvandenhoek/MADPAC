//
//  TIFURLRequestSerializer.swift
//  Pods
//
//  Created by Antoine van der Lee on 30/11/15.
//
//

import Foundation

public protocol TIFURLRequestSerializer {
    func serialize(request: URLRequest) -> URLRequest
    func serialize(parameters: inout [String: Any], forToken token: TIFAPI)
}
