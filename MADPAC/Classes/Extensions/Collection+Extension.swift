//
//  Collection+Extension.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 29/10/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import Foundation

extension Collection {
    func safeSuffix(_ maxLength: Self.IndexDistance) -> Array<Element> {
        guard let index = self.index(endIndex, offsetBy: -maxLength, limitedBy: startIndex) else {
            return Array(self[startIndex ..< endIndex])
        }
        return Array(self[index ..< endIndex])
    }
}
