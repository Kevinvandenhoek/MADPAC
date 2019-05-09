//
//  MADImageLoadingCollectionViewCell.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 30/05/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import EasyPeasy

class MADPhotoLoadingCollectionViewCell: MADBaseLoadingCollectionViewCell {
    
    override class var cellHeight: CGFloat { return MADPhotoCollectionViewCell.cellHeight }
    
    let loadingTitleView = MADLoadingView()
    let loadingCategoryView = MADLoadingView()
    
    override func setup() {
        super.setup()
        
        backgroundColor = UIColor.MAD.cellBackgroundColor
        layoutViews()
    }
    
    func layoutViews() {
        
        let marginLeft: CGFloat = 10.5
        let marginRight: CGFloat = 14.5
        let labelSpacing: CGFloat = 5
        let marginBottom: CGFloat = 10
        
        
        let width = CGFloat.random(min: 20, max: 40)
        addSubview(loadingCategoryView)
        loadingCategoryView.easy.layout([Left(marginLeft), Bottom(marginBottom), Width(width), Height(12)])
        
        let extraMargin = CGFloat.random(min: 10, max: 40)
        addSubview(loadingTitleView)
        loadingTitleView.easy.layout([Left(marginLeft), Bottom(labelSpacing).to(loadingCategoryView, .top), Right(marginRight + extraMargin), Height(14)])
    }
}
