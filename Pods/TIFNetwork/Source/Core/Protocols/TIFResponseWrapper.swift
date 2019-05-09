//
//  TIFResponseWrapper.swift
//  Pods
//
//  Created by Antoine van der Lee on 30/11/15.
//
//

import Moya

public protocol TIFResponseWrapper: Decodable {
    var error: Error? { get set }
    var innerResponseObject: Moya.Response? { get set }
}
