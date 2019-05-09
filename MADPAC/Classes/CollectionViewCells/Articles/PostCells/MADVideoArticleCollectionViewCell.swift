//
//  MADVideoArticleCollectionViewCell.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 09/09/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import Foundation
import EasyPeasy

class MADVideoArticleCollectionViewCell: MADArticleCollectionViewCell {
    
    let currentlyPlayingOverlay: MADTextBlurOverlay = MADTextBlurOverlay()
    let lowContrastOverlay: MADView = MADView()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        displayCurrentlyPlaying(false)
    }
    
    override func setup() {
        super.setup()
        
        imageContainerView.addSubview(currentlyPlayingOverlay)
        currentlyPlayingOverlay.easy.layout([Edges()])
        
        addSubview(lowContrastOverlay)
        lowContrastOverlay.isUserInteractionEnabled = false
        lowContrastOverlay.easy.layout([Left().to(imageContainerView, .right), Top(), Bottom(), Right()])
        lowContrastOverlay.alpha = 0
        
        updateColors()
    }
    
    func displayCurrentlyPlaying(_ currentlyPlaying: Bool) {
        currentlyPlayingOverlay.display(text: currentlyPlaying ? "Wordt afgespeeld" : nil)
        lowContrastOverlay.alpha = currentlyPlaying ? 0.4 : 0
    }
    
    override func updateColors() {
        super.updateColors()
        
        currentlyPlayingOverlay.updateColors()
        lowContrastOverlay.backgroundColor = UIColor.MAD.UIElements.cellBackground
    }
}
