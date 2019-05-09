//
//  TIFUIProgressView.swift
//
//  Created by Antoine van der Lee on 25/06/15.
//  Copyright (c) 2015 Triple IT. All rights reserved.
//

import UIKit
import TIFExtensions

@IBDesignable
open class TIFProgressView: UIView {
    
    internal var progressView:UIView!
    internal var trackView:UIView!
    
    internal var trackViewWidthConstraint:NSLayoutConstraint!
    
    @IBInspectable open var progressColor:UIColor = UIColor.red {
        didSet {
            progressView?.backgroundColor = progressColor
        }
    }
    
    @IBInspectable open var trackColor:UIColor = UIColor.white {
        didSet {
            trackView?.backgroundColor = trackColor
        }
    }
    
    @IBInspectable open fileprivate(set) var progress:CGFloat = 0.5 {
        didSet {
            progress = min(progress, 1.0)
            progress = max(progress, 0.0)
            
            updateTrackForProgress()
        }
    }
    
    @IBInspectable open var roundedCorners:Bool = true {
        didSet {
            if roundedCorners {
                trackView?.layer.cornerRadius = height / 2
                progressView?.layer.cornerRadius = height / 2
            } else {
                trackView?.layer.cornerRadius = 0
                progressView?.layer.cornerRadius = 0
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup(){
        trackView = UIView()
        trackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(trackView)

        addConstraint(NSLayoutConstraint(item: trackView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: trackView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: trackView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: trackView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0))
        trackView.backgroundColor = UIColor.white
        trackView.backgroundColor = trackColor
        
        progressView = UIView()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressView)

        progressView.backgroundColor = progressColor
        addConstraint(NSLayoutConstraint(item: progressView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: progressView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: progressView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        trackViewWidthConstraint = NSLayoutConstraint(item: progressView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width * progress)
        addConstraint(trackViewWidthConstraint)
        setNeedsUpdateConstraints()
        layoutIfNeeded()
    }
    
    internal func updateTrackForProgress(triggerLayoutIfNeeded:Bool? = true){
        trackViewWidthConstraint.constant = width * progress
        setNeedsUpdateConstraints()
        if triggerLayoutIfNeeded == true {
            layoutIfNeeded()
        }
    }
    
    override open func layoutSubviews() {
        updateTrackForProgress(triggerLayoutIfNeeded: false)
        super.layoutSubviews()
        
        if roundedCorners {
            trackView?.layer.cornerRadius = height / 2
            progressView?.layer.cornerRadius = height / 2
        }
    }
    
}

public extension TIFProgressView {
    
    public func setProgress(_ progress:CGFloat, animated:Bool = false, completion:(() -> Void)? = nil){
        removeAllAnimations()
        layoutIfNeeded()
        
        if animated {
            UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: { [weak self] in
                self?.progress = progress
                self?.layoutIfNeeded()
            }, completion: { (_) in
              completion?()
            })
        } else {
            self.progress = progress
            layoutIfNeeded()
            completion?()
        }
    }
}
