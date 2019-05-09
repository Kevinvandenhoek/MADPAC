//
//  MADVideoCollectionViewCell.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 30/05/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import TIFExtensions
import EasyPeasy
import AVFoundation

protocol MADVideoCollectionViewCellDelegate: AnyObject {
    func startedPlaying(videoCell: MADVideoCollectionViewCell)
    func stoppedPlaying(videoCell: MADVideoCollectionViewCell)
}

class MADVideoCollectionViewCell: MADPostCollectionViewCell {

    override class var cellHeight: CGFloat { return 350 }
    
    var transformingVideoView: TransformingVideoPlayerView? = TransformingVideoPlayerView()
    var video: MADVideo?
    var post: MADPost?
    
    weak var delegate: MADVideoCollectionViewCellDelegate?
    
    override func setup() {
        super.setup()
        
        layoutViews()
        setupViews()
        prepareForReuse()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        transformingVideoView?.prepareForReuse()
    }
    
    override func update(with post: MADPost) {
        self.post = post
        guard let transformingVideoView = transformingVideoView else { return }
        transformingVideoView.update(with: post)
        delegate?.startedPlaying(videoCell: self)
        
        guard self.transformingVideoView?.playButton.fixedBlur == false else { return }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.transformingVideoView?.playButton.fixBlur()
        }
    }
    
    override func willAppear() {
        if UserPreferences.autoPlay {
            transformingVideoView?.videoView.player?.play()
        }
    }
    
    override func willDisappear() {
        guard let transformingVideoView = transformingVideoView else { return }
        transformingVideoView.videoView.player?.pause()
        delegate?.stoppedPlaying(videoCell: self)
    }
    
    override func updateColors() {
        super.updateColors()
        
        transformingVideoView?.updateColors()
    }
}

// MARK: View setup
extension MADVideoCollectionViewCell {
    func layoutViews() {
        layoutTransformingVideoView()
    }
    
    func layoutTransformingVideoView() {
        guard let transformingVideoView = transformingVideoView else { return }
        cellContainerView.addSubview(transformingVideoView)
        transformingVideoView.easy.layout([Edges()])
    }
    
    func setupViews() {
        // TODO: Whatever?
    }
}

extension MADVideoCollectionViewCell: NavigationTransitioningView {
    func allows(view: UIView) -> Bool {
        return type(of: view.self) == TransformingVideoPlayerView.self
    }
    
    func getTransitioningView<T>() -> T? where T : UIView {
        return transformingVideoView as? T
    }
    
    func prepareForTransition(presenting: Bool, isTargetVc: Bool, transitionProperties: TransitionProperties) {
        transformingVideoView?.prepareForTransition(presenting: presenting, isTargetVc: isTargetVc, transitionProperties: transitionProperties)
    }
    
    func animateInTransition(presenting: Bool, isTargetVc: Bool) {
        transformingVideoView?.animateInTransition(presenting: presenting, isTargetVc: isTargetVc)
    }
    
    func endTransition(presenting: Bool, completed: Bool) {
        transformingVideoView?.endTransition(presenting: presenting, completed: completed)
        if presenting && completed {
            transformingVideoView = nil
        }
    }
    
    func getTargetRect() -> CGRect? {
        return self.bounds
    }
    
    func receive(transitionedView: UIView) {
        guard let receivedTransformingVideoView = transitionedView as? TransformingVideoPlayerView else { return }
        self.transformingVideoView?.removeFromSuperview()
        cellContainerView.addSubview(receivedTransformingVideoView)
        receivedTransformingVideoView.easy.layout([Edges()])
        transformingVideoView = receivedTransformingVideoView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        transformingVideoView?.layoutSubviews()
    }
}
