//
//  Array+Helper.swift
//
//  Created by Antoine van der Lee on 18/06/15.
//  Copyright (c) 2015 Triple IT. All rights reserved.
//

import Foundation

public extension Array {
    
    /// Returns value from given index. If out of bounds, return nil
    public subscript (safe index: Int) -> Element? {
        return index < count && index >= 0 ? self[index] : nil
    }
    
    /// Returns value from given index. If out of bounds, return nil
    public func object(forIndex index: Int) -> Element? {
        return index < count && index >= 0 ? self[index] : nil
    }
    
    /// Set the UIViews in the array on hidden
    public func setViewsHidden(_ hidden: Bool) {
        compactMap { (item) -> UIView? in
            return item as? UIView
        }.forEach { (view) in
            view.isHidden = hidden
        }
    }
    
    /// Take the first 'elementsCount' elements, started from 0
    public func takeElements(elementsCount: Int) -> [Element] {
        if (elementsCount > count) {
            return Array(self[0..<count])
        }
        return Array(self[0..<elementsCount])
    }
    
    /// This will find the index of the given object and remove it from the array
    public mutating func remove<U: Equatable>(object: U) {
        for (index, objectToCompare) in enumerated() {
            guard let to = objectToCompare as? U, object == to else { continue }
            remove(at: index)
            break
        }
    }
    
    /**
     Checks if test returns true for all the elements in self
     - parameter test: Function to call for each element
     - returns: True if test returns true for all the elements in self
     */
    public func all (_ test: (Element) -> Bool) -> Bool {
        for item in self {
            if !test(item) {
                return false
            }
        }
        
        return true
    }
    
    /// This can be used for caroussel elements
    public var infinitScrollingValue: Array {
        var result = self
        if result.count == 1 {
            // No paging at all
            return result
        }
        
        // Insert last value in the beginning
        result.insert(self.last!, at: 0)
        
        // Insert first value at the end
        result.append(self.first!)
        
        return result
    }
}

public extension Array where Element:Equatable {
    public func removeDuplicates() -> [Element] {
        var result = [Element]()
        
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        
        return result
    }
}
