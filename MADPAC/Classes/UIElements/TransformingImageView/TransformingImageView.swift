//
//  TransformingImageView.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 22/07/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import EasyPeasy

class TransformingImageView: MADView {
    
    enum Style {
        case article
        case photo
        case interview
    }
    
    var isInDetail: Bool = false
    let imageView = MADImageView(image: nil)
    let gradientImageView = UIImageView(image: #imageLiteral(resourceName: "videocell_gradient"))
    let titleLabel = MADLabel(style: .title)
    let categoryAndDateLabel = MADLabel(style: .category)
    var video: MADVideo?
    var style: Style { didSet { updateStyle() } }
    
    let videoPlayerView = MADVideoPlayerView()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) not implemented")
    }
    
    init(style: Style) {
        self.style = style
        super.init(frame: CGRect.zero)
        updateStyle()
    }
    
    override func setup() {
        super.setup()
        
        clipsToBounds = false
        layoutViews()
        setupViews()
        updateColors()
        prepareForReuse()
    }
    
    func prepareForReuse() {
        titleLabel.text = nil
        imageView.image = nil
        categoryAndDateLabel.text = nil
        
        videoPlayerView.isHidden = true
        videoPlayerView.alpha = 0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layoutSubviews()
    }
}

// MARK: Updating
extension TransformingImageView {
    func update(with post: MADPost) {
        titleLabel.text = post.title
        self.video = MADVideo(from: post)
        
        if let date = post.date {
            if style != .interview, let category = post.category {
                categoryAndDateLabel.text = "\(category.uppercased()) - \(date)"
            } else {
                categoryAndDateLabel.text = "\(date)"
            }
        } else {
            categoryAndDateLabel.text = "CATEGORIE - Datum"
        }
        
        imageView.setImage(with: post.imageUrl)
        videoPlayerView.update(with: post, play: false)
        
        videoPlayerView.isHidden = post.videoUrl == nil || post.videoUrl == ""
    }
}

// MARK: View setup
extension TransformingImageView {
    func layoutViews() {
        addSubview(imageView)
        imageView.easy.layout([Edges()])
        
        addSubview(gradientImageView)
        gradientImageView.easy.layout([Edges()])
        
        addSubview(categoryAndDateLabel)
        addSubview(titleLabel)
        
        addSubview(videoPlayerView)
        videoPlayerView.easy.layout([Edges()])
        
        let marginLeft: CGFloat = 15
        let marginBottom: CGFloat = 15
        let labelSpacing: CGFloat = 9.5
        if style != .interview {
            let labelWidth: CGFloat = 290 // TODO: Should be [prio 999 width 290] & [prio 1000 Right >= 71]
            
            categoryAndDateLabel.easy.layout([Left(marginLeft), Bottom(marginBottom), Width(labelWidth)])
            
            titleLabel.easy.layout([Left(marginLeft), Bottom(labelSpacing).to(categoryAndDateLabel, .top), Width(labelWidth)])
        } else {
            let marginRight = marginLeft
            categoryAndDateLabel.easy.layout([Left(marginLeft), Bottom(marginBottom), Right(marginRight + 10)])
            titleLabel.easy.layout([Left(marginLeft), Bottom(labelSpacing).to(categoryAndDateLabel, .top), Right(marginRight)])
        }
    }
    
    func setupViews() {
        titleLabel.numberOfLines = 0
        
        gradientImageView.contentMode = .scaleToFill
        gradientImageView.alpha = MADConstants.gradientAlpha
        imageView.delegate = self
        imageView.displayPlaceholder(true)
        videoPlayerView.delegate = self
    }
    
    private func updateStyle() {
        switch style {
        case .article:
            titleLabel.alpha = isInDetail ? 1 : 0
            categoryAndDateLabel.alpha = isInDetail ? 1 : 0
            gradientImageView.alpha = isInDetail ? 1 : 0
            return
        case .photo:
            return
        case.interview:
            return
        }
    }
}

extension TransformingImageView: MADImageViewDelegate {
    func placeholder(isDisplaying: Bool) {
        gradientImageView.alpha = isDisplaying ? 0 : MADConstants.gradientAlpha
    }
}

extension TransformingImageView: NavigationTransitioningView {
    func allows(view: UIView) -> Bool {
        return false
    }
    
    func getTransitioningView<T>() -> T? where T : UIView {
        return nil
    }
    
    func prepareForTransition(presenting: Bool, isTargetVc: Bool, transitionProperties: TransitionProperties) {
        // Nothing
        if !presenting {
            videoPlayerView.alpha = 0
        }
    }
    
    func animateInTransition(presenting: Bool, isTargetVc: Bool) {
        if style == .article {
            titleLabel.alpha = presenting ? 1 : 0
            categoryAndDateLabel.alpha = presenting ? 1 : 0
            gradientImageView.alpha = presenting ? MADConstants.gradientAlpha : 0
        }
        if presenting {
            videoPlayerView.alpha = 1
        }
    }
    
    func endTransition(presenting: Bool, completed: Bool) {
        isInDetail = (presenting && completed) || (!presenting && !completed)
        if !isInDetail {
            videoPlayerView.videoView.player?.pause()
        } else {
            videoPlayerView.alpha = 1
        }
    }
    
    func getTargetRect() -> CGRect? {
        return nil
    }
    
    func receive(transitionedView: UIView) {
        fatalError("Does not receive")
    }
}

extension TransformingImageView: MADVideoPlayerDelegate {
    func playbackStatusChanged(to status: MADVideoView.PlaybackStatus) {
        // TODO: Maybe
    }
    
    func didFinishPlaying() {
        // TODO: Maybe
    }
}

extension TransformingImageView: ColorUpdatable {
    
    func updateColors() {
        titleLabel.textColor = UIColor.MAD.white
        categoryAndDateLabel.textColor = UIColor.MAD.lightGray
        imageView.backgroundColor = UIColor.clear
        imageView.updateColors()
    }
}
