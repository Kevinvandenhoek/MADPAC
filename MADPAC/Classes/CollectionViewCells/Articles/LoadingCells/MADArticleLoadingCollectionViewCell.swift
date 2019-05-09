//
//  MADArticleLoadingCell.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 30/05/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import EasyPeasy

class MADArticleLoadingCollectionViewCell: MADBaseLoadingCollectionViewCell {
    
    override class var cellHeight: CGFloat { return MADArticleCollectionViewCell.cellHeight }
    
    let loadingImageView = MADLoadingView()
    let loadingTitleView = MADLoadingView()
    let loadingCategoryView = MADLoadingView()
    
    override func setup() {
        super.setup()
        
        backgroundColor = UIColor.MAD.cellBackgroundColor
        layoutViews()
    }
    
    func layoutViews() {
        addSubview(loadingImageView)
        loadingImageView.easy.layout([Left(), Height().like(self, .height), Width().like(self, .height)])
        loadingImageView.layer.cornerRadius = 0
        
        let marginLeft: CGFloat = 10.5
        let marginRight: CGFloat = 14.5
        let marginTop: CGFloat = 12.5
        let marginBottom: CGFloat = 10
        
        
        let width = CGFloat.random(min: 20, max: 40)
        addSubview(loadingCategoryView)
        loadingCategoryView.easy.layout([Left(marginLeft).to(loadingImageView, .right), Bottom(marginBottom), Width(width), Height(12)])
        
        let extraMargin = CGFloat.random(min: 10, max: 40)
        addSubview(loadingTitleView)
        loadingTitleView.easy.layout([Left(marginLeft).to(loadingImageView, .right), Top(marginTop), Right(marginRight + extraMargin), Height(14)])
    }
}
