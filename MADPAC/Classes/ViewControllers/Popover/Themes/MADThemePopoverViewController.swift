//
//  MADThemePopoverViewController.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 05/08/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import EasyPeasy

class MADThemePopoverViewController: MADPopoverViewController {
    
    let titleLabel = MADLabel(style: .custom)
    let descriptionLabel = MADLabel(style: .custom)
    
    let darkButton = MADButton()
    let lightButton = MADButton()
    
    override func setup() {
        super.setup()
        
        containerView.addSubview(titleLabel)
        titleLabel.easy.layout([Left(35), Top(26), Right(35)])
        titleLabel.text = "THEMAS"
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont(fontStyle: .regular, size: 20)
        
        containerView.addSubview(descriptionLabel)
        descriptionLabel.textAlignment = .center
        descriptionLabel.easy.layout([Left(35), Top(10).to(titleLabel), Right(35)])
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = "Er zijn twee kleurthemas om uit te kiezen, deze instelling kun je later ook nog wijzigen in het 'bolletjesmenu'."
        descriptionLabel.font = UIFont(fontStyle: .regular, size: 14)
        
        containerView.addSubview(darkButton)
        darkButton.easy.layout([Size(76), CenterX(-58), Top(26).to(descriptionLabel), Bottom(41)])
        darkButton.backgroundColor = UIColor.MAD.offBlack
        darkButton.layer.cornerRadius = 23
        darkButton.layer.borderWidth = 3
        darkButton.addTarget(self, action: #selector(darkThemeTapped), for: .touchUpInside)
        
        containerView.addSubview(lightButton)
        lightButton.easy.layout([Size(76), CenterX(58), Top(26).to(descriptionLabel), Bottom(41)])
        lightButton.backgroundColor = UIColor.MAD.offWhite
        lightButton.layer.cornerRadius = 23
        lightButton.layer.borderWidth = 3
        lightButton.addTarget(self, action: #selector(lightThemeTapped), for: .touchUpInside)
        
        updateColors()
    }
    
    @objc func darkThemeTapped() {
        UserPreferences.darkMode = true
    }
    
    @objc func lightThemeTapped() {
        UserPreferences.darkMode = false
    }
    
    override func updateColors() {
        super.updateColors()
        
        titleLabel.textColor = UIColor.MAD.UIElements.primaryText
        descriptionLabel.textColor = UIColor.MAD.UIElements.primaryText
        
        darkButton.layer.borderColor = UserPreferences.darkMode ? UIColor.MAD.hotPink.cgColor : UIColor.clear.cgColor
        lightButton.layer.borderColor = UserPreferences.darkMode ? UIColor.clear.cgColor : UIColor.MAD.hotPink.cgColor
    }
}
