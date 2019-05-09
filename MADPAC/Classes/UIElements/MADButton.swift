//
//  MADButton.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 30/05/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit

class MADButton: UIButton {
    
    var title: String? {
        didSet {
            setTitle(title, for: .normal)
            setTitle(title, for: .highlighted)
            setTitle(title, for: .selected)
            setTitle(title, for: .disabled)
            setTitle(title, for: .focused)
            setTitle(title, for: .reserved)
        }
    }
    
    var image: UIImage? {
        didSet {
            setImage(image, for: .normal)
            setImage(image, for: .highlighted)
            setImage(image, for: .selected)
            setImage(image, for: .disabled)
            setImage(image, for: .focused)
            setImage(image, for: .reserved)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override var isHighlighted: Bool {
        didSet {
            animateHighlighted(isHighlighted)
        }
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    func setup() {
        clipsToBounds = true
    }
    
    func animateHighlighted(_ highlighted: Bool) {
        let offsetX = self.transform.tx
        let offsetY = self.transform.ty
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [.allowUserInteraction, .curveEaseInOut], animations: { [weak self] in
            self?.transform = highlighted ? CGAffineTransform.identity.translatedBy(x: offsetX, y: offsetY).scaledBy(x: 0.9, y: 0.9) : CGAffineTransform.identity.translatedBy(x: offsetX, y: offsetY)
        })
    }
}
