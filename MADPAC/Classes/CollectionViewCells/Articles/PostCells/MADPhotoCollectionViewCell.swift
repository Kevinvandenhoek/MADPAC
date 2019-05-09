//
//  MADPhotoCollectionViewCell.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 30/05/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import TIFExtensions
import EasyPeasy

class MADPhotoCollectionViewCell: MADPostCollectionViewCell {

    override class var cellHeight: CGFloat { return 350 }
    var transformingImageView: TransformingImageView?
    
    override func setup() {
        super.setup()
        
        transformingImageView = TransformingImageView(style: .photo)
        
        layoutViews()
        setupViews()
        
        cellContainerView.layer.cornerRadius = MADPostsCollectionViewController.cellCornerRadius
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        transformingImageView?.prepareForReuse()
    }
    
    override func update(with post: MADPost) {
        transformingImageView?.update(with: post)
    }
}

// MARK: View setup
extension MADPhotoCollectionViewCell {
    func layoutViews() {
        
        cellContainerView.addSubview(imageContainerView)
        imageContainerView.easy.layout([Edges()])
        
        if let transformingImageView = transformingImageView {
            imageContainerView.addSubview(transformingImageView)
            transformingImageView.easy.layout([Edges()])
        }
    }
    
    func setupViews() {
        transformingImageView?.prepareForReuse()
    }
}

extension MADPhotoCollectionViewCell: NavigationTransitioningView {
    func allows(view: UIView) -> Bool {
        return type(of: view.self) == TransformingImageView.self
    }
    
    func prepareForTransition(presenting: Bool, isTargetVc: Bool, transitionProperties: TransitionProperties) {
        // Nothing
    }
    
    func animateInTransition(presenting: Bool, isTargetVc: Bool) {
        // Nothing
    }
    
    func endTransition(presenting: Bool, completed: Bool) {
        // Nothing
    }
    
    func getTransitioningView<T>() -> T? where T : UIView {
        return self.transformingImageView as? T
    }
    
    func getTargetRect() -> CGRect? {
        return imageContainerView.frame
    }
    
    func receive(transitionedView: UIView) {
        guard let imageView = transitionedView as? TransformingImageView else {
            transitionedView.removeFromSuperview()
            return
        }
        self.transformingImageView?.removeFromSuperview()
        self.imageContainerView.addSubview(imageView)
        self.transformingImageView = imageView
        self.transformingImageView?.easy.layout([Edges()])
    }
}
