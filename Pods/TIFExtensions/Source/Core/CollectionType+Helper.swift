//
//  CollectionType+Extension.swift
//  MyVodafone
//
//  Created by Jeroen Bakker on 13/04/16.
//  Copyright © 2016 Triple IT. All rights reserved.
//

import Foundation

public extension Collection {
    
    /// Filter given type and returns an array of given type
    func filterToType<T>(_ type: T.Type) -> [T] {
        return compactMap({ $0 as? T })
    }
}
