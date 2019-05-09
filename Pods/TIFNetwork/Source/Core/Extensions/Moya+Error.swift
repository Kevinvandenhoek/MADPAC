//
//  NSError+Moya.swift
//  Pods
//
//  Created by Antoine van der Lee on 17/11/15.
//
//

import Foundation
import Moya

public enum TIFError: Swift.Error {
    case innerObjectMapping
    case responseWrapperMapping
}

public extension MoyaError {
    public func unwrapMoyaUnderlyingError() -> Swift.Error? {        
        switch self {
        case MoyaError.underlying(let error, _):
            return error
        default:
            return nil
        }
    }
}
