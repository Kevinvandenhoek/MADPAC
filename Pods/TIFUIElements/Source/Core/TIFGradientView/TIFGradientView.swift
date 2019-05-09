//
//  TIFGradientView.swift
//
//  Created by Antoine van der Lee on 23/06/15.
//  Copyright (c) 2015 Triple IT. All rights reserved.
//

import UIKit

@IBDesignable
open class TIFGradientView: UIView {
    
    public var horizontalGradient = true
    
    /// Start color of gradient, default is black
    @IBInspectable open var startColor:UIColor = UIColor.black {
        didSet {
            drawGradientLayer()
        }
    }
    /// Mid color of gradient, default is black
    @IBInspectable open var midColor:UIColor = UIColor.black {
        didSet {
            drawGradientLayer()
        }
    }
    /// End color of gradient, default is black
    @IBInspectable open var endColor:UIColor = UIColor.black {
        didSet {
            drawGradientLayer()
        }
    }
    
    /// Start location of gradient, default is 0.0
    @IBInspectable open var startLocation:CGFloat = 0.0 {
        didSet {
            drawGradientLayer()
        }
    }
    /// Mid location of gradient, default is 1.0
    @IBInspectable open var midLocation:CGFloat = 1.0 {
        didSet {
            drawGradientLayer()
        }
    }
    /// End location of gradient, default is 1.0
    @IBInspectable open var endLocation:CGFloat = 1.0 {
        didSet {
            drawGradientLayer()
        }
    }
    
    private var gradientLayer:CAGradientLayer?
    
    override init(frame:CGRect){
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup(){
        backgroundColor = UIColor.clear
        
        // Add gradient on top of imageViwe
        drawGradientLayer()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = self.bounds
    }
    
    /// Draw gradient
    private func drawGradientLayer(){
        gradientLayer?.removeFromSuperlayer()

        gradientLayer = CAGradientLayer()
        gradientLayer?.colors = [startColor.cgColor, midColor.cgColor, endColor.cgColor]
        gradientLayer?.locations = [NSNumber(value: Float(startLocation)), NSNumber(value: Float(midLocation)), NSNumber(value: Float(endLocation))]
        
        if horizontalGradient {
            gradientLayer?.startPoint = CGPoint(x: 0.5, y: 0)
            gradientLayer?.endPoint = CGPoint(x: 0.5, y: 1)
        } else {
            gradientLayer?.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer?.endPoint = CGPoint(x: 1, y: 0.5)
        }
        
        layer.insertSublayer(gradientLayer!, at: 0)
    }
}
