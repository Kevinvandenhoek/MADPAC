//
//  MADBaseCollectionViewCell.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 30/05/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit

class MADBaseCollectionViewCell: UICollectionViewCell, AnimatableCell, ColorUpdatable {
    
    private var animateScaleInPixels: CGFloat { return 12 * (bounds.width / UIScreen.main.bounds.width) }
    
    func animateIn() {
        alpha = 0
        transform = CGAffineTransform.identity.scaledBy(x: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.1) { [weak self] in
            guard let `self` = self else { return }
            self.alpha = 1
            self.transform = CGAffineTransform.identity
        }
    }
    
    func animateOut() {
        UIView.animate(withDuration: 0.1) { [weak self] in
            guard let `self` = self else { return }
            self.alpha = 0
            self.transform = CGAffineTransform.identity.scaledBy(x: 0.8, y: 0.8)
        }
    }
    
    class var cellHeight: CGFloat { return 100 }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override var isHighlighted: Bool {
        didSet {
            doHighlightAnimation(isHighlighted)
        }
    }
    
    func setup() {
        prepareForReuse()
        updateColors()
    }
    
    func doHighlightAnimation(_ highlight: Bool) {
        if highlight {
            UIView.animate(withDuration: UserPreferences.slowAnimations ? 2 : 0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: [.allowUserInteraction, .curveEaseInOut], animations: { [weak self] in
                guard let `self` = self else { return }
                self.displayHighlight(highlight)
            })
        } else {
            UIView.animate(withDuration: UserPreferences.slowAnimations ? 1 : 0.2, delay: 0, options: [.allowUserInteraction, .curveEaseIn], animations: {
                [weak self] in
                guard let `self` = self else { return }
                self.displayHighlight(highlight)
            })
        }
    }
    
    func displayHighlight(_ highlight: Bool) {
        let scale = getAnimateScale(highlight: highlight)
        transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale)
    }
    
    func getAnimateScale(highlight: Bool) -> CGFloat {
        let height: CGFloat = self.frame.size.width
        let amount: CGFloat = (height - self.animateScaleInPixels) / height
        let scale: CGFloat = highlight ? amount : 1
        return scale
    }
    
    func willAppear() {
        updateColors()
    }
    
    func willDisappear() {
        // Override
    }
    
    func updateColors() {
        // Override
    }
}
