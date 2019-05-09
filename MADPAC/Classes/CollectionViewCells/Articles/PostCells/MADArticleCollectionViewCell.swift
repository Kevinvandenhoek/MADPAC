//
//  MADArticleCollectionViewCell.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 30/05/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import TIFExtensions
import EasyPeasy
import Nuke

class MADArticleCollectionViewCell: MADPostCollectionViewCell {
    
    override class var cellHeight: CGFloat { return 125 }

    let titleLabel = MADLabel(style: .title)
    let categoryLabel = MADLabel(style: .category)
    let dateLabel = MADLabel(style: .date)
    var transformingImageView: TransformingImageView?
    
    override func setup() {
        super.setup()
        
        transformingImageView = TransformingImageView(style: .article)
        layoutViews()
        setupViews()
        updateColors()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        dateLabel.text = nil
        categoryLabel.text = nil
        transformingImageView?.prepareForReuse()
    }
    
    override func update(with post: MADPost) {
        super.update(with: post)
        
        titleLabel.text = post.title
        dateLabel.text = post.date
        categoryLabel.text = post.category?.uppercased()
        transformingImageView?.update(with: post)
    }
    
    override func updateColors() {
        super.updateColors()
        
        titleLabel.updateStyle()
        categoryLabel.updateStyle()
        dateLabel.updateStyle()
        transformingImageView?.updateColors()
    }
}

// MARK: View setup
extension MADArticleCollectionViewCell {
    func layoutViews() {
        cellContainerView.addSubview(imageContainerView)
        imageContainerView.easy.layout([Left(), Height().like(self, .height), Width().like(self, .height)])
        
        if let transformingImageView = transformingImageView {
            imageContainerView.addSubview(transformingImageView)
            transformingImageView.easy.layout([Edges()])
        }
        
        let marginLeft: CGFloat = 10.5
        let marginRight: CGFloat = 14.5
        let marginTop: CGFloat = 5.5
        let marginBottom: CGFloat = 10
        
        cellContainerView.addSubview(dateLabel)
        dateLabel.easy.layout([Left(marginLeft).to(imageContainerView, .right), Bottom(marginBottom), Right(marginRight)])
        
        cellContainerView.addSubview(categoryLabel)
        categoryLabel.easy.layout([Left(marginLeft).to(imageContainerView, .right), Bottom().to(dateLabel, .top), Right(marginRight)])
        
        cellContainerView.addSubview(titleLabel)
        titleLabel.easy.layout([Left(marginLeft).to(imageContainerView, .right), Top(marginTop), Right(marginRight), Bottom(<=0).to(categoryLabel, .top)])
    }
    
    func setupViews() {
        titleLabel.numberOfLines = 3
    }
}

extension MADArticleCollectionViewCell: NavigationTransitioningView {
    
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
