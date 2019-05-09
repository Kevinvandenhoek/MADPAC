//
//  MADCollectionView.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 30/05/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit

class MADCollectionView: UICollectionView {
    
    private var registeredCellTypes: [UICollectionViewCell.Type] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    init() {
        super.init(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        setup()
    }
    
    func setup() {
        backgroundColor = UIColor.clear
        delaysContentTouches = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
    }
    
    func registerIfNeeded(_ cellType: UICollectionViewCell.Type) {
        guard !registeredCellTypes.contains(where: { $0.reuseIdentifier == cellType.reuseIdentifier }) else { return }
        
        register(cellType.self, forCellWithReuseIdentifier: cellType.reuseIdentifier)
        registeredCellTypes.append(cellType.self)
    }
}
