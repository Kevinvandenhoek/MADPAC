//
//  UICollectionView+Helper.swift
//
//  Created by Antoine van der Lee on 16/06/15.
//  Copyright (c) 2015 Triple IT. All rights reserved.
//

import UIKit

public extension UICollectionView {
    
    /// Reload UICollectionView animated
    func reloadAnimated(){
        if self.numberOfSections > 0 {
            self.reloadData()
            self.reloadSections(IndexSet(integer: 0))
        } else if let dataSource = self.dataSource, let numberOfSections = dataSource.numberOfSections?(in: self), numberOfSections > 0 {
            self.reloadData()
            self.reloadSections(IndexSet(integer: 0))
        } else {
            self.reloadData()
        }
    }
    
    /// Reload UICollectionView with a completion block
    func reloadWith(completion: @escaping () -> Void){
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
    
        self.reloadData()
    
        CATransaction.commit()
    }
}

public extension UICollectionReusableView {
    
    /// Returns string of class name
    static var reuseIdentifierValue: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
}

public extension UICollectionViewCell {
    
    /// Returns string of class name
    static var reuseIdentifier: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
}
