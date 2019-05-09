//
//  MADLinkButton.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 06/08/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit

class MADLinkButton: MADOptionsButton {
    
    private var url: URL?
    
    override func setup() {
        super.setup()
        
        self.contentHorizontalAlignment = .left
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 17, bottom: 0, right: 17)
    }
    
    override func updateColors() {
        super.updateColors()
        
        self.backgroundColor = UIColor.MAD.UIElements.optionsBackground
        self.setTitleColor(UIColor.MAD.UIElements.secondaryText, for: .normal)
        self.titleLabel?.font = UIFont(fontStyle: .regular, size: 18)
    }
    
    override func animateHighlighted(_ highlighted: Bool) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.highlightView.alpha = highlighted ? 0.05 : 0
            self?.setTitleColor(highlighted ? UIColor.MAD.UIElements.primaryText : UIColor.MAD.UIElements.secondaryText, for: .normal)
        }
    }
    
    func update(with link: MADLink) {
        self.setTitle(link.title, for: .normal)
        self.url = link.link
        self.addTarget(self, action: #selector(didTap), for: .touchUpInside)
    }
    
    @objc func didTap() {
        guard let url = self.url else { return }
        UIApplication.shared.open(url, options: [:])
    }
}
