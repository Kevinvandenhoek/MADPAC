//
//  NSTimeInterval+Helper.swift
//
//  Created by AvdLee on 22/12/14.
//  Copyright (c) 2014 Triple IT. All rights reserved.
//

import Foundation

public extension TimeInterval {
    
    /// Returns the time interval into a string value in hours:minutes:seconds (e.g. 09:15:34)
    func stringValue(removeHoursIfEmpty:Bool = true) -> String {
        if(self.isNaN){
            return "00:00"
        }
        
        var value = self
        
        if value < 0 {
            value = 0
        }
        
        let hours:Int = Int(value / 3600)
        let minutes:Int = Int((value.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds:Int = Int(value.truncatingRemainder(dividingBy: 60))
        
        if (hours > 0 || removeHoursIfEmpty == false){
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    /// Returns the amount of minutes as string from the time interval
    var durationStringValue:String? {
        let minutes = Int(self / 60)
        return String(format: "%d min", minutes)
    }    
}
