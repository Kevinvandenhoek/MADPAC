//
//  Dictionary+Helper.swift
//
//  Created by Hans Zaadnoordijk on 18/08/15.
//  Copyright (c) 2015 Triple IT. All rights reserved.
//

import Foundation

public func allKeysForValue<K, V : Equatable>(_ val: V, inDictionary dict: [K : V]) -> [K] {
    return dict.filter({ $1 == val }).map() { $0.0 }
}

public extension Dictionary {
    
   public mutating func addDictionary(_ other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}

public extension Dictionary {
    public func mapKeys<U> (_ transform: (Key) -> U) -> Array<U> {
        var results: Array<U> = []
        for k in self.keys {
            results.append(transform(k))
        }
        return results
    }
    
    public func mapValues<U> (_ transform: (Value) -> U) -> Array<U> {
        var results: Array<U> = []
        for v in self.values {
            results.append(transform(v))
        }
        return results
    }
    
    public func map<U> (_ transform: (Value) -> U) -> Array<U> {
        return self.mapValues(transform)
    }
    
    public func map<U> (_ transform: (Key, Value) -> U) -> Array<U> {
        var results: Array<U> = []
        for k in self.keys {
            results.append(transform(k as Key, self[ k ]! as Value))
        }
        return results
    }
    
    public func map<K: Hashable, V> (_ transform: (Key, Value) -> (K, V)) -> Dictionary<K, V> {
        var results: Dictionary<K, V> = [:]
        for k in self.keys {
            if let value = self[ k ] {
                let (u, w) = transform(k, value)
                results.updateValue(w, forKey: u)
            }
        }
        return results
    }
}

@discardableResult
public func +=<K, V> (left: inout Dictionary<K, V>, right: Dictionary<K, V>) -> Dictionary<K, V> {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
    return left
}

public extension Dictionary where Key: ExpressibleByStringLiteral, Value: AnyObject {
    func removeNilValues() -> Dictionary<Key, Value> {
        var dict = self
        
        let keysToRemove = dict.keys.filter { dict[$0] is NSNull }
        for key in keysToRemove {
            dict.removeValue(forKey: key)
        }
        
        return dict
    }
}
