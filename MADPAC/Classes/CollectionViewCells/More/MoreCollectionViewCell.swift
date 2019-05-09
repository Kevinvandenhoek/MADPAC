//
//  MoreCollectionViewCell.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 14/07/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import EasyPeasy

class MoreCollectionViewCell: MADBaseCollectionViewCell {
    
    let label = MADLabel(style: .custom)
    
    override func setup() {
        super.setup()
        
        addSubview(label)
        label.font = UIFont.MAD.avenirMedium(size: 20)
        label.textColor = UIColor.MAD.UIElements.primaryText
        label.easy.layout([Edges()])
        label.textAlignment = .center
    }
    
    func updateWith(title: String?, enabled: Bool) {
        label.text = title
        label.alpha = enabled ? 1 : 0.6
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        label.text = nil
    }
    
    override func updateColors() {
        super.updateColors()
        
        label.textColor = UIColor.MAD.UIElements.primaryText
    }
}
