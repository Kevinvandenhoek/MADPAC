//
//  MADLabel.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 30/05/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit

class MADLabel: UILabel {
    
    enum Style {
        case title
        case category
        case date
        case custom
        case videoTime
        case navigationTitle
        case videoTitle
        case seek
    }
    
    var style: Style = .title {
        didSet {
            updateStyle()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    init(style: Style) {
        super.init(frame: CGRect.zero)
        self.style = style
        setup()
    }
    
    func setup() {
        isUserInteractionEnabled = false
        updateStyle()
    }
    
    func updateStyle() {
        switch style {
        case .title:
            self.font = UIFont(fontStyle: .bold, size: 19)
            self.textColor = UIColor.MAD.UIElements.primaryText
        case .category:
            self.font = UIFont(fontStyle: .regular, size: 12)
            self.textColor = UIColor.MAD.UIElements.secondaryText
        case .date:
            self.font = UIFont(fontStyle: .light, size: 12)
            self.textColor = UIColor.MAD.UIElements.tertiaryText
        case .navigationTitle:
            self.font = UIFont.MAD.avenirMedium(size: 17)
            self.textColor = UIColor.MAD.UIElements.primaryText
        case .videoTime:
            self.font = UIFont(fontStyle: .bold, size: 14)
            self.textColor = UIColor.MAD.offWhite
        case .videoTitle:
            self.font = UIFont(fontStyle: .bold, size: 16)
            self.textColor = UIColor.MAD.offWhite
        case .seek:
            self.font = UIFont(fontStyle: .bold, size: 14)
            self.textColor = UIColor.MAD.offWhite
        case .custom:
            return
        }
    }
}
