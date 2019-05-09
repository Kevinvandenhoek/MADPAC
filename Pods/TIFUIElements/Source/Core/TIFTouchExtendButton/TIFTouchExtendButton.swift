//
//  TIFTouchExtendButton.swift
//
//  Created by Antoine van der Lee on 09/09/15.
//  Copyright (c) 2015 Triple IT. All rights reserved.
//

import UIKit

@IBDesignable
open class TIFTouchExtendButton: UIButton {

    @IBInspectable open var touchMargin:CGFloat = 20.0
    
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let extendedArea = bounds.insetBy(dx: -touchMargin, dy: -touchMargin)
        return extendedArea.contains(point)
    }
}
