//
//  GlobalMethods.swift
//
//  Created by Antoine van der Lee on 22/06/15.
//  Copyright (c) 2015 Triple IT. All rights reserved.
//

import Foundation

/// PerformBlock after given delay
public func performBlock(_ block:@escaping () -> Void, afterDelay delay:DispatchTimeInterval){
    let deadlineTime = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
        block()
    }
}
