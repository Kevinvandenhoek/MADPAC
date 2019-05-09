//
//  MADVideoBottomView.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 15/07/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import EasyPeasy

class MADVideoBottomView: MADView {
    
    let titleLabel = MADLabel(style: .title)
    let arrowImageView = MADImageView(image: #imageLiteral(resourceName: "icon_forward").withRenderingMode(.alwaysTemplate))
    
    override func setup() {
        super.setup()
        
        addSubview(titleLabel)
        titleLabel.easy.layout([Left(15), Top(6), Bottom(6), Right(65)])
        titleLabel.numberOfLines = 3
        
        addSubview(arrowImageView)
        arrowImageView.easy.layout([Width(40), Height(40), CenterY(), Right(10)])
        
        updateColors()
    }
    
    func update(with post: MADPost) {
        titleLabel.text = post.title
    }
    
    func updateArrowInNavigationAnimation(for isPresenting: Bool) {
        if isPresenting {
            arrowImageView.transform = CGAffineTransform.identity.translatedBy(x: -20, y: 0)
        } else {
            arrowImageView.transform = CGAffineTransform.identity
        }
        arrowImageView.alpha = isPresenting ? 0 : 1
    }
}

extension MADVideoBottomView: ColorUpdatable {
    func updateColors() {
        titleLabel.updateStyle()
        arrowImageView.tintColor = UIColor.MAD.UIElements.secondaryText
    }
}
