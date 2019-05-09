//
//  MADTextBlurOverlay.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 09/09/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import EasyPeasy

class MADTextBlurOverlay: MADView {
    
    var blurEffect: UIVisualEffect { return isVisible ? UIBlurEffect(style: UserPreferences.darkMode ? .dark : .prominent) : UIVisualEffect() }
    let blurView = UIVisualEffectView(effect: UIVisualEffect())
    
    let label = MADLabel(style: .custom)
    var isVisible: Bool = false
    
    override func setup() {
        super.setup()
        
        backgroundColor = .clear
        
        addSubview(blurView)
        blurView.backgroundColor = .clear
        blurView.easy.layout([Edges()])
        
        addSubview(label)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.alpha = 0
        label.font = UIFont.MAD.avenirMedium(size: 14)
        label.easy.layout([Edges(10)])
        
    }
    
    func display(text: String?) {
        isVisible = text != nil
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let `self` = self else { return }
            self.blurView.effect = self.blurEffect
            self.label.alpha = self.isVisible ? 1 : 0
            self.label.text = text
        }
    }
}

extension MADTextBlurOverlay: ColorUpdatable {
    
    func updateColors() {
        label.textColor = UIColor.MAD.UIElements.secondaryText
        blurView.effect = blurEffect
    }
}
