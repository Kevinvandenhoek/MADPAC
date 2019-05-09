//
//  TIFAttributedButton.swift
//
//  Created by Antoine van der Lee on 21/07/15.
//  Copyright (c) 2015 Triple IT. All rights reserved.
//

import UIKit

@IBDesignable open class TIFAttributedButton: UIButton {

    @IBInspectable open var isLink:Bool = false {
        didSet {
            updateTitle()
        }
    }

    // MARK: Setup
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        updateTitle()
    }
    
    private func updateTitle(){
        let attrTitle = attributedTitle(for: .normal) ?? (NSAttributedString(string: title(for: .normal) ?? ""))
        let attrString = NSMutableAttributedString(attributedString: attrTitle)
        
        attrString.addAttributes(attributesForState(.normal), range: NSMakeRange(0, attrTitle.length))
        setAttributedTitle(attrString, for: .normal)
        
        let highlightedAttrString = NSMutableAttributedString(attributedString: attrTitle)
        highlightedAttrString.addAttributes(attributesForState(.highlighted), range: NSMakeRange(0, attrTitle.length))
        setAttributedTitle(highlightedAttrString, for: .highlighted)
    }
    
    private func attributesForState(_ state: UIControlState) -> [NSAttributedStringKey : AnyObject] {
        let style = NSMutableParagraphStyle()
        var attributes = [
            NSAttributedStringKey.paragraphStyle: style,
            NSAttributedStringKey.font: titleLabel!.font,
            NSAttributedStringKey.foregroundColor: titleColor(for: state)!
        ]
        
        if isLink && state == .normal {
            attributes[NSAttributedStringKey.underlineStyle] = NSNumber(value: 1)
        } else {
            attributes[NSAttributedStringKey.underlineStyle] = NSNumber(value: 0)
        }
        
        return attributes as [NSAttributedStringKey : AnyObject]
    }
}
