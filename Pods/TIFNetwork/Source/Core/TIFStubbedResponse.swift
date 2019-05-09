//
//  TIFMockInfo.swift
//  Pods
//
//  Created by Tim Bakker on 08-12-15.
//
//

import Foundation

public final class TIFStubbedResponse: NSObject, NSCoding {
    let requestPath: String
    
    let responseCode: Int
    let responseData: Data?
    
    let responseError: Error?
    
    public init(requestPath: String, responseCode: Int = 200, responseData: Data? = nil, responseError: Error? = nil) {
        self.requestPath = requestPath
        self.responseCode = responseCode
        self.responseData = responseData
        self.responseError = responseError
    }
    
    required convenience public init?(coder decoder: NSCoder) {
        let requestPath = decoder.decodeObject(forKey: "requestPath") as? String ?? ""
        let responseData = decoder.decodeObject(forKey: "responseData") as? Data
        let responseError = decoder.decodeObject(forKey: "responseError") as? Error
        let responseCode = decoder.decodeInteger(forKey: "responseCode")
        
        self.init(requestPath: requestPath, responseCode: responseCode, responseData: responseData, responseError: responseError)
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(requestPath, forKey: "requestPath")
        coder.encode(responseCode, forKey: "responseCode")

        if let responseData = responseData {
            coder.encode(responseData, forKey: "responseData")
        }
        if let responseError = responseError {
            coder.encode(responseError, forKey: "responseError")
        }
    }
}


