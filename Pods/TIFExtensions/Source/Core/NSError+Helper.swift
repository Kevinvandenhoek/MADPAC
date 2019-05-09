//
//  NSError+Helper.swift
//
//  Created by Antoine van der Lee on 27/07/15.
//  Copyright (c) 2015 Triple IT. All rights reserved.
//

import Foundation

public extension NSError {
    
    /// Checks for network connection error
    public func isNetworkConnectionError() -> Bool {
        let networkErrors = [NSURLErrorNetworkConnectionLost, NSURLErrorNotConnectedToInternet]
        
        return self.domain == NSURLErrorDomain && networkErrors.contains(self.code)
    }
}
