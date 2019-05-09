//
//  UIView+Helper.swift
//
//  Created by AvdLee on 24/11/14.
//  Copyright (c) 2014 Triple IT. All rights reserved.
//

import UIKit

public extension UIView {
 
    /// Returns frame size height
    var height: CGFloat {
        get {
            return frame.size.height
        }
        set (height) {
            frame.size.height = height
        }
    }
    
    /// Returns frame size width
    var width: CGFloat {
        get {
            return frame.size.width
        }
        set (width) {
            frame.size.width = width
        }
    }
    
    /// Returns frame origin x
    var x: CGFloat {
        get {
            return frame.origin.x
        }
        set (x) {
            frame.origin.x = x
        }
    }
    
    /// Returns frame origin y
    var y: CGFloat {
        get {
            return frame.origin.y
        }
        set (y) {
            frame.origin.y = y
        }
    }
    
    /// Hides view animated or not animated with a completion block and a duration of 0.3
    func set(hidden: Bool, animated: Bool = false, completion: (() -> Void)? = nil) {
        set(hidden: hidden, animated: animated, duration: 0.3, completion: completion)
    }
    
    /// Hides view animated or not animated with a duration and a completion block
    func set(hidden: Bool, animated: Bool = false, duration: TimeInterval, completion: (() -> Void)?) {
        removeAllAnimations()
        
        if self.isHidden == hidden && self.alpha == (hidden ? 0.0 : 1.0) {
            completion?()
            return
        }
        
        if animated {
            if hidden == false {
                // Make sure the view is visible for animation, but alpha is hidden
                self.alpha = 0.0
                self.isHidden = false
            }

            
            UIView.animate(withDuration: duration, animations: { () -> Void in
                self.alpha = hidden ? 0.0 : 1.0
            }, completion: { (finished) -> Void in
                self.isHidden = hidden
                
                completion?()
            })
        } else {
            self.isHidden = hidden
            self.alpha = hidden ? 0.0 : 1.0
            
            completion?()
        }
    }
    
    /// Hides view animated or not animated with contraints and a completion block
    func set(hidden: Bool, animated: Bool, usingConstraintsFromSuperView superView: UIView, updateBottomConstraint: Bool = false, toValue: CGFloat = 0, updateLayout: Bool = true) {
        constraints
            .filter { (constraint) -> Bool in
                return constraint.firstAttribute == NSLayoutAttribute.height && constraint.firstItem as? UIView == self
            }
            .forEach { (constraint) in
                constraint.constant = hidden ? 0 : intrinsicContentSize.height
            }

        if updateBottomConstraint {
            superView.constraints
                .filter { (constraint) -> Bool in
                    return constraint.firstAttribute == NSLayoutAttribute.bottom && constraint.secondItem as? UIView == self
                }
                .forEach { (constraint) in
                    constraint.constant = hidden ? 0 : toValue
                }
        }
        
        if animated {
            if !hidden {
                self.isHidden = hidden
            }
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                superView.layoutIfNeeded()
            }, completion: { (finished) -> Void in
                self.isHidden = hidden
            })
        } else {
            if updateLayout {
                self.layoutIfNeeded()
            }
            
            self.isHidden = hidden
        }
    }
    
    /// Hides view animated or not animated using the alpha of the view with a duration of 0.2
    func setAlphaHidden(_ hidden:Bool, animated:Bool){
        if animated {
            UIView.animate(withDuration: 0.2, animations: { 
                self.alpha = hidden ? 0.0 : 1.0
            })
        } else {
            self.alpha = hidden ? 0.0 : 1.0
        }
    }
    
    /// Sets the alpha of the view aniamted with a default duration of 0.3
    func setAlphaAnimated(alpha: CGFloat, duration:TimeInterval? = nil){
        UIView.animate(withDuration: duration ?? 0.3, animations: { () -> Void in
            self.alpha = alpha
        })
    }
    
    /// Returns the height constraint, returns nil if not found
    var heightConstraint:NSLayoutConstraint? {
        return constraints.filter({ $0.firstAttribute == NSLayoutAttribute.height && $0.firstItem as? UIView == self }).first
    }
    
    /// Returns the width constraint, returns nil if not found
    var widthConstraint:NSLayoutConstraint? {
        return constraints.filter({ $0.firstAttribute == NSLayoutAttribute.width && $0.firstItem as? UIView == self }).first
    }
    
    /// Returns the trailing/right constraint, returns nil if not found
    var rightConstraint:NSLayoutConstraint? {
        return superview?.constraints.filter({ $0.firstAttribute == NSLayoutAttribute.right && $0.firstItem as? UIView == self }).first
    }
    
    /// Returns the leading/left constraint, returns nil if not found
    var leftConstraint:NSLayoutConstraint? {
        return superview?.constraints.filter({ $0.firstAttribute == NSLayoutAttribute.left && $0.firstItem as? UIView == self }).first
    }
    
    func animateCornerRadius(toValue:CGFloat, duration:TimeInterval) {
        let cornerRadiusAnimation = CABasicAnimation(keyPath: "cornerRadius")
        cornerRadiusAnimation.fromValue = layer.cornerRadius
        cornerRadiusAnimation.toValue = toValue
        cornerRadiusAnimation.duration = duration
        cornerRadiusAnimation.fillMode = kCAFillModeForwards
        cornerRadiusAnimation.isRemovedOnCompletion = false
        self.layer.add(cornerRadiusAnimation, forKey: "cornerRadiusAnimation")
    }
    
    /// Remove all animations
    func removeAllAnimations() {
        CATransaction.begin()
        layer.removeAllAnimations()
        CATransaction.commit()
    }
    
    func setupWith(xibName: String) -> UIView {
        let xibView = Bundle.main.loadNibNamed(xibName, owner: self, options: nil)?.first as! UIView
        
        let viewBindings = ["xibView" :xibView]
        
        xibView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(xibView)
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[xibView]|", options: NSLayoutFormatOptions.alignAllLastBaseline, metrics: nil, views: viewBindings))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[xibView]|", options: NSLayoutFormatOptions.alignAllLastBaseline, metrics: nil, views: viewBindings))
        
        return xibView
    }
    
    /// Returns nibValue of UIView
    class var nibValue: UINib {
        get {
            let nibName = NSStringFromClass(self).components(separatedBy: ".").last!
            return UINib(nibName: nibName, bundle: nil)
        }
    }
    
    /// Remove all subviews
    func removeAllSubViews() {
        subviews.forEach { (subView) in
            subView.removeFromSuperview()
        }
    }
    
    /// Adds parallax effect with motions
    func applyParallaxWith(intensity: Int) {
        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = -intensity
        horizontal.maximumRelativeValue = intensity
        
        let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        vertical.minimumRelativeValue = -intensity
        vertical.maximumRelativeValue = intensity
        
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontal, vertical]
        self.addMotionEffect(group)
    }
    
    /// This will allow xib files for UIViews
    class func instanceFromNib<T>() -> T {
        guard let nib = nibValue.instantiate(withOwner: nil, options: nil).filterToType(T.self).first else {
            fatalError("UIView doesn't have a Nib file")
        }
        return nib
    }
    
    /// Applies dropshadow to the UIView
    func applyDropShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 2
    }
    
    // This can be used on optional views to send them to back
    func sendToBack(){
        superview?.sendSubview(toBack: self)
    }
    
    // This can be used on optional views to send them to back
    func bringToFront(){
        superview?.bringSubview(toFront: self)
    }
}
