//
//  MADPostCollectionViewCell.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 30/05/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import EasyPeasy
import WebKit

class MADPostCollectionViewCell: MADBaseCollectionViewCell, PostUpdatable {
    
    let cellContainerView = MADView()
    let imageContainerView =  MADView()
    
    private let shadowRadius: CGFloat = 6
    private let shadowOffset: CGFloat = 3
    private var shadowOpacity: Float { return UserPreferences.darkMode ? 0 : 0.15 }
    
    override func setup() {
        backgroundColor = UIColor.clear
        
        //imageContainerView.layer.cornerRadius = MADPostsCollectionViewController.cellCornerRadius
        addSubview(cellContainerView)
        cellContainerView.easy.layout([Edges()])
        cellContainerView.layer.cornerRadius = MADPostsCollectionViewController.cellCornerRadius
        cellContainerView.clipsToBounds = true
        setupShadow()
    }
    
    func update(with post: MADPost) {
        // Override
    }
    
    func setupShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = shadowOpacity
    }
    
    override func displayHighlight(_ highlight: Bool) {
        super.displayHighlight(highlight)
        self.layer.shadowRadius = highlight ? (shadowRadius / 2) : shadowRadius
        self.layer.shadowOpacity = highlight ? shadowOpacity * 2 : shadowOpacity
        self.layer.shadowOffset = CGSize(width: 0, height: highlight ? (shadowOffset / 2) : shadowOffset)
    }
    
    override func updateColors() {
        super.updateColors()
        
        cellContainerView.backgroundColor = UIColor.MAD.UIElements.cellBackground
    }
}
