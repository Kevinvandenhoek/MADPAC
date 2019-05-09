//
//  MADHighlightedButton.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 31/10/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit

class MADHighlightedButton: MADButton, ColorUpdatable {
    
    override func setup() {
        super.setup()
        
        titleLabel?.font = UIFont(fontStyle: .bold, size: 12)
        layer.borderWidth = 2
        layer.cornerRadius = 3
        updateColors()
    }
    
    func updateColors() {
        setTitleColor(UIColor.MAD.UIElements.secondaryText, for: .normal)
        setTitleColor(UIColor.MAD.UIElements.primaryText, for: .highlighted)
        layer.borderColor = UIColor.MAD.UIElements.tertiaryText.cgColor
    }
    
    override func animateHighlighted(_ highlighted: Bool) {
        UIView.animate(withDuration: 0.1) { [weak self] in
            self?.backgroundColor = highlighted
                ? UIColor.gray.withAlphaComponent(0.2)
                : UIColor.clear
            
            self?.layer.borderColor = highlighted
                ? UIColor.MAD.UIElements.secondaryText.cgColor
                : UIColor.MAD.UIElements.tertiaryText.cgColor
        }
    }
}
