//
//  MADOptionsButton.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 06/08/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import EasyPeasy

class MADOptionsButton: MADButton, ColorUpdatable {
    
    let selectedView = UIView()
    let highlightView = UIView()
    
    var didSetSelected: Bool = false
    
    override func setup() {
        super.setup()
        
        insertSubview(highlightView, at: 0)
        highlightView.easy.layout([Edges()])
        highlightView.alpha = 0
        
        insertSubview(selectedView, at: 0)
        selectedView.easy.layout([Edges()])
        selectedView.alpha = 0
        updateColors()
    }
    
    override func animateHighlighted(_ highlighted: Bool) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.highlightView.alpha = highlighted ? 0.05 : 0
        }
    }
    
    func setSelected(_ selected: Bool) {
        didSetSelected = selected
        selectedView.alpha = selected ? 0.05 : 0
        updateColors()
    }
    
    func updateColors() {
        setTitleColor(didSetSelected ? UIColor.MAD.UIElements.primaryText : UIColor.MAD.UIElements.tertiaryText, for: .normal)
        backgroundColor = UIColor.MAD.UIElements.optionsBackground
        highlightView.backgroundColor = UserPreferences.darkMode ? UIColor.white : UIColor.black
        selectedView.backgroundColor = UserPreferences.darkMode ? UIColor.white : UIColor.black
    }
}
