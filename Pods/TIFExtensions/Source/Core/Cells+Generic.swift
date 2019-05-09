//
//  Cells+Generic.swift
//  Buienradar
//
//  Created by Antoine van der Lee on 19/01/16.
//  Copyright © 2016 Triple. All rights reserved.
//

import Foundation
import UIKit

public protocol Reusable: class {
    static var reuseIdentifierString: String { get }
    static func nibValue() -> UINib?
    
    /// Use this property to indicate a cell as a prototype cell. This will prevent a reregister of a nib based cell, which causes an error like "Could not load NIB in bundle"
    static var isPrototypeCell: Bool { get }
}

public extension Reusable {
    static var reuseIdentifierString: String { return String(describing: self) }
    static func nibValue() -> UINib? { return nil }
    static var isPrototypeCell: Bool { return false }
}

public protocol NibReusable : Reusable {
}

public extension NibReusable {
    static func nibValue() -> UINib? { return UINib(nibName: String(describing: self), bundle: nil) }
}

public extension UITableView {
    func registerReusableCell<T: UITableViewCell & Reusable>(_: T.Type) {
        if let nib: UINib = T.nibValue() {
            self.register(nib, forCellReuseIdentifier: T.reuseIdentifierString)
        } else {
            self.register(T.self, forCellReuseIdentifier: T.reuseIdentifierString)
        }
    }
    
    func dequeueReusableCell<T: UITableViewCell & Reusable>(indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withIdentifier: T.reuseIdentifierString, for: indexPath) as! T
    }
    
    func registerReusableHeaderFooterView<T: UITableViewHeaderFooterView & Reusable>(_: T.Type) {
        if let nib: UINib = T.nibValue() {
            self.register(nib, forHeaderFooterViewReuseIdentifier: T.reuseIdentifierString)
        } else {
            self.register(T.self, forHeaderFooterViewReuseIdentifier: T.reuseIdentifierString)
        }
    }
    
    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView & Reusable>() -> T {
        return self.dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifierString) as! T
    }
}

public extension UICollectionView {
    func registerReusableCell<T: UICollectionViewCell & Reusable>(_: T.Type) {
        if let nib: UINib = T.nibValue() {
            self.register(nib, forCellWithReuseIdentifier: T.reuseIdentifier)
        } else {
            self.register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
        }
    }
    
    func dequeueReusableCell<T: UICollectionViewCell & Reusable>(indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
    
    func registerReusableSupplementaryView<T: Reusable>(elementKind: String, _: T.Type) {
        if let nib: UINib = T.nibValue() {
            self.register(nib, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: T.reuseIdentifierString)
        } else {
            self.register(T.self, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: T.reuseIdentifierString)
        }
    }
    
    func dequeueReusableSupplementaryView<T: UICollectionReusableView & Reusable>(elementKind: String, indexPath: IndexPath) -> T {
        return self.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: T.reuseIdentifierString, for: indexPath) as! T
    }
}
