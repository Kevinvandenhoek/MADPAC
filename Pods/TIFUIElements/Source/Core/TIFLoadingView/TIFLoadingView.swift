//
//  TIFLoadingView.swift
//
//  Created by Antoine van der Lee on 19/06/15.
//  Copyright (c) 2015 Triple IT. All rights reserved.
//

import UIKit

@IBDesignable
open class TIFLoadingView: UIView {

    // MARK: Override properties
    override open var isHidden:Bool {
        didSet {
            if isHidden {
                hide(animated: false)
            } else {
                show()
            }
        }
    }
    @IBInspectable open var initialShowing:Bool = false {
        didSet {
            show()
        }
    }
    @IBInspectable open var spinnerImage:UIImage? = UIImage(named: TIFLoadingView.kDefaultSpinnerImageName){
        didSet {
            loaderImageView?.image = spinnerImage
        }
    }
    
    // MARK: Private properties
    private var loaderImageView:UIImageView?
    private var animating:Bool = false
    private static let kDefaultSpinnerImageName = "icon_spinner"

    // MARK: Setup
    /// Use this method to instantiate with a custom spinner image
    public init(frame: CGRect = CGRect.zero, spinnerImage: UIImage?){
        super.init(frame: frame)
        self.spinnerImage = spinnerImage ?? UIImage(named: TIFLoadingView.kDefaultSpinnerImageName)
        setup()
    }
    
    override public convenience init(frame: CGRect) {
        self.init(frame: frame, spinnerImage: UIImage(named: TIFLoadingView.kDefaultSpinnerImageName))
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setup(){
        backgroundColor = UIColor.clear
        isHidden = true
        
        let loaderImageView = UIImageView()
        loaderImageView.translatesAutoresizingMaskIntoConstraints = false
        self.loaderImageView = loaderImageView
        addSubview(loaderImageView)
        addConstraint(NSLayoutConstraint(item: loaderImageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: loaderImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        loaderImageView.contentMode = .scaleAspectFit
        
        if let image = spinnerImage {
            loaderImageView.image = image
            addConstraint(NSLayoutConstraint(item: loaderImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: image.size.width))
            addConstraint(NSLayoutConstraint(item: loaderImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: image.size.height))
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(TIFLoadingView.onForeground(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    @objc private func onForeground(_ notification:Notification){
        if animating == true {
            runSpinAnimation()
        }
    }
    
    private func runSpinAnimation(){
        loaderImageView?.layer.removeAllAnimations()
        
        var rotationAnimation:CABasicAnimation
        rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(value: Double.pi * 2.0)
        rotationAnimation.duration = 1
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = MAXFLOAT
        rotationAnimation.isRemovedOnCompletion = false
        loaderImageView?.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    /// Show loading view
    open func show(){
        guard !animating else { return } // Already animating

        animating = true
        isHidden = false
        runSpinAnimation()
    }
    
    /// Hide loading view, animated on default
    open func hide(animated:Bool = true){
        guard animating else { return } // Nothing to hide
        
        animating = false
        
        if animated {
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                self?.alpha = 0
            }, completion: { [weak self] (_) in
                self?.isHidden = true
                self?.loaderImageView?.layer.removeAllAnimations()
                self?.alpha = 1.0
            })
        } else {
            isHidden = true
            loaderImageView?.layer.removeAllAnimations()
            alpha = 1.0
        }
    }
}
