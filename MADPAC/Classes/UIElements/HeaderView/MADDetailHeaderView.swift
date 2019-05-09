//
//  MADHeaderView.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 15/07/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import EasyPeasy

class MADDetailHeaderView: MADView, NavigationTransitioningView {
    
    var transformingImageView: TransformingImageView?
    
    override func setup() {
        super.setup()
        
        self.backgroundColor = UIColor.clear
        setupTransitioningView()
    }
    
    func setupTransitioningView() {
        guard self.transformingImageView == nil else { return }
        self.transformingImageView = TransformingImageView(style: .article)
        addSubview(transformingImageView!)
        transformingImageView?.easy.layout([Edges()])
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews {
            if subview.isUserInteractionEnabled && !subview.isHidden && subview.alpha > 0 && subview.point(inside: convert(point, to: subview), with: event) {
                if subview == transformingImageView && transformingImageView?.videoPlayerView.isHidden == true {
                    continue
                }
                return true
            }
        }
        return false
    }
    
    func allows(view: UIView) -> Bool {
        return type(of: view.self) == TransformingImageView.self
    }
    
    func getTransitioningView<T>() -> T? where T : UIView {
        return transformingImageView as? T
    }
    
    func getTargetRect() -> CGRect? {
        return self.bounds
    }
    
    func receive(transitionedView: UIView) {
        guard let receivedImageView = transitionedView as? TransformingImageView else {
            fatalError()
        }
        self.transformingImageView?.removeFromSuperview()
        self.transformingImageView = receivedImageView
        addSubview(receivedImageView)
        self.transformingImageView?.easy.layout([Edges()])
    }
    
    func prepareForTransition(presenting: Bool, isTargetVc: Bool, transitionProperties: TransitionProperties) {
        // Nothing
    }
    
    func animateInTransition(presenting: Bool, isTargetVc: Bool) {
        // Nothing
    }
    
    func endTransition(presenting: Bool, completed: Bool) {
        if !presenting && completed {
            transformingImageView = nil
        }
    }
}
