//
//  TransformingVideoView.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 16/07/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import TIFExtensions
import EasyPeasy
import AVFoundation
import AVKit

class TransformingVideoPlayerView: MADView {
    
    var controlsView: MADVideoControlsView = MADVideoControlsView()
    var videoView = MADVideoView(useAVPlayerPool: true)
    
    var isInDetailView: Bool = false
    let playYOffset: CGFloat = -25.5
    
    let imageView = MADImageView(image: nil)
    let videoContainerView = MADView()
    let gradientImageView = UIImageView(image: #imageLiteral(resourceName: "videocell_gradient"))
    let forwardArrowView = MADImageView(image: #imageLiteral(resourceName: "icon_forward").withRenderingMode(.alwaysTemplate))
    let titleLabel = MADLabel(style: .title)
    let categoryAndDateLabel = MADLabel(style: .category)
    let playButton = MADPlayButton()
    var video: MADVideo?
    var wasPlaying: Bool = false
    private var isBeingPopped: Bool = false {
        didSet {
            videoContainerView.alpha = isBeingPopped ? 0 : 1
        }
    }
    
    override func setup() {
        super.setup()
        
        clipsToBounds = false
        layoutViews()
        setupViews()
        updateColors()
    }
    
    func prepareForReuse() {
        titleLabel.text = nil
        imageView.image = nil
        categoryAndDateLabel.text = nil
        videoView.alpha = 0
        videoView.releasePlayer()
        playButton.display(state: .stopped)
        playButton.reset()
        self.forwardArrowView.alpha = 0
    }
    
    @objc func didTapPlay() {
        videoView.player?.togglePlay()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        controlsView.layoutSubviews()
        if !isBeingPopped {
            videoContainerView.layoutSubviews()
        }
    }
    
    deinit {
        videoView.releasePlayer() // important
        print("Deinit \(self.description)")
    }
}

// View updating
extension TransformingVideoPlayerView {
    
    func update(with post: MADPost) {
        titleLabel.text = post.title
        self.video = MADVideo(from: post)
        controlsView.updateFor(post: post)
        
        if let category = post.category, let date = post.date {
            categoryAndDateLabel.text = "\(category.uppercased()) - \(date)"
        } else {
            categoryAndDateLabel.text = "CATEGORIE - Datum"
        }
        
        imageView.setImage(with: post.imageUrl)
        videoView.alpha = 0
        videoView.update(with: post)
    }
    
    func swapBetweenControlsAndCellLayout(controls visible: Bool) {
        controlsView.alpha = visible ? 1 : 0
        if visible {
            controlsView.showControls(animated: false)
        } else {
            controlsView.hideControls(animated: false, duration: 0.7, ignoringPlayButton: true)
            playButton.alpha = videoView.playbackStatus == .playing ? 0 : 1
        }
        
        titleLabel.alpha = visible ? 0 : 1
        categoryAndDateLabel.alpha = visible ? 0 : 1
        gradientImageView.alpha = visible ? 0 : 1
        forwardArrowView.isHidden = visible
        
        playButton.easy.layout([CenterY(visible ? controlsView.basePlayOffset : playYOffset)])
    }
}

// View setup
extension TransformingVideoPlayerView {
    
    func setupViews() {
        //videoView.alpha = 0
        
        titleLabel.numberOfLines = 0
        
        gradientImageView.contentMode = .scaleToFill
        gradientImageView.alpha = MADConstants.gradientAlpha
        imageView.delegate = self
        imageView.displayPlaceholder(true)
        
        playButton.addTarget(self, action: #selector(didTapPlay), for: .touchUpInside)
        self.forwardArrowView.alpha = 0
        
        controlsView.delegate = self
        controlsView.hideControls(animated: false)
        swapBetweenControlsAndCellLayout(controls: false)
        
        videoView.delegate = self
    }
}

extension TransformingVideoPlayerView: MADImageViewDelegate {
    func placeholder(isDisplaying: Bool) {
        gradientImageView.alpha = isDisplaying ? 0 : MADConstants.gradientAlpha
    }
}

extension TransformingVideoPlayerView: NavigationTransitioningView {
    func allows(view: UIView) -> Bool {
        return false
    }
    
    func getTransitioningView<T>() -> T? where T : UIView {
        return nil
    }
    
    func prepareForTransition(presenting: Bool, isTargetVc: Bool, transitionProperties: TransitionProperties) {
        isBeingPopped = transitionProperties.isPopping
        if isBeingPopped {
            videoView.removeFromSuperview()
            wasPlaying = videoView.player?.isPlaying() == true
            videoView.player?.pause()
        }
    }
    
    func animateInTransition(presenting: Bool, isTargetVc: Bool) {
        if presenting {
            swapBetweenControlsAndCellLayout(controls: true)
        } else {
            swapBetweenControlsAndCellLayout(controls: false)
            if videoView.playbackStatus != .playing {
                playButton.alpha = 1
            }
        }
        
        layoutIfNeeded()
    }
    
    func endTransition(presenting: Bool, completed: Bool) {
        if isBeingPopped {
            videoContainerView.addSubview(videoView)
            if wasPlaying { videoView.player?.play() }
            videoView.alpha = 0
            videoView.easy.layout([Edges()])
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.videoView.alpha = 1
            }
        }
        isBeingPopped = false
        
        if (completed && !presenting) || (!completed && presenting) {
            isInDetailView = false
            swapBetweenControlsAndCellLayout(controls: false)
            videoView.playbackMode = .silent
        } else {
            isInDetailView = true
            swapBetweenControlsAndCellLayout(controls: true)
            videoView.playbackMode = UserPreferences.session.muteVideo ? .silent : .normal
        }
        
    }
    
    func getTargetRect() -> CGRect? {
        return nil
    }
    
    func receive(transitionedView: UIView) {
        fatalError("Does not receive")
    }
}

extension TransformingVideoPlayerView: MADVideoViewDelegate {
    
    func didFinishPlaying() {
        // TODO: Secure this from starting to play while not on screen
        if !isInDetailView {
            guard let item = videoView.player?.currentItem else { return }
            videoView.player?.seek(to: CMTime.init(seconds: 0, preferredTimescale: item.duration.timescale))
            videoView.player?.play()
        }
    }
    
    func handlePeriodicUpdating(for player: AVPlayer) {
        controlsView.handlePeriodicUpdating(for: player)
    }
    
    func assetStatusChanged(to status: MADVideoView.AssetStatus) {
        // TODO: None yet
    }
    
    func playbackStatusChanged(to status: MADVideoView.PlaybackStatus) {
        if status == .playing {
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.videoView.alpha = 1
            }
        }
        if isInDetailView {
            controlsView.handlePlaybackStatus(status)
        } else {
            if status == .playing {
                playButton.hide(animated: true, completion: { [weak self] (completed) in
                    if completed {
                        self?.playButton.display(state: status)
                    }
                })
            } else {
                playButton.display(state: status)
                playButton.show(animated: true)
            }
        }
    }
}

extension TransformingVideoPlayerView: MADVideoControlsViewDelegate {
    
    func getPlayer() -> AVPlayer? {
        return videoView.player
    }
    
    func videoIsPlaying() -> Bool {
        return videoView.player?.isPlaying() == true
    }
    
    func finishSeek(wasPlaying: Bool) {
        if wasPlaying {
            videoView.player?.play()
        }
    }

    func didTapMaximize() {
        let videoVC = MADPlayerViewController(player: self.getPlayer(), delegate: self)
        parentViewController?.present(videoVC, animated: true)
    }
    
    func didTapVolume() {
        // TODO: Volume
    }
    
    func getPlayButton() -> MADPlayButton? {
        return playButton
    }
    
    func didRequestSeek(to percentage: CGFloat) {
        videoView.seek(to: percentage)
    }
}

// View layout
extension TransformingVideoPlayerView {
    
    func layoutViews() {
        addSubview(imageView)
        imageView.easy.layout([Edges()])
        
        addSubview(videoContainerView)
        videoContainerView.easy.layout([Edges()])
        
        videoContainerView.addSubview(videoView)
        videoView.easy.layout([Edges()])
        
        addSubview(gradientImageView)
        gradientImageView.easy.layout([Edges()])
        
        let marginLeft: CGFloat = 15
        let labelWidth: CGFloat = 290 // TODO: Should be [prio 999 width 290] & [prio 1000 Right >= 71]
        let marginBottom: CGFloat = 15
        let labelSpacing: CGFloat = 9.5
        
        addSubview(categoryAndDateLabel)
        categoryAndDateLabel.easy.layout([Left(marginLeft), Bottom(marginBottom), Width(labelWidth)])
        
        addSubview(titleLabel)
        titleLabel.easy.layout([Left(marginLeft), Bottom(labelSpacing).to(categoryAndDateLabel, .top), Width(labelWidth)])
        
        addSubview(forwardArrowView)
        forwardArrowView.easy.layout([Width(40), Height(40), Right(15), CenterY().to(titleLabel)])
        
        addSubview(controlsView)
        controlsView.easy.layout([Edges()])
        
        let playSize: CGFloat = 73.5
        addSubview(playButton)
        playButton.easy.layout([CenterX(), CenterY(playYOffset), Width(playSize), Height(playSize)])
    }
}

extension TransformingVideoPlayerView: ColorUpdatable {
    
    func updateColors() {
        titleLabel.textColor = UIColor.MAD.white
        categoryAndDateLabel.textColor = UIColor.MAD.lightGray
        imageView.backgroundColor = UIColor.MAD.offWhite
        forwardArrowView.tintColor = UIColor.MAD.UIElements.secondaryText
        imageView.updateColors()
    }
}

extension TransformingVideoPlayerView: MADPlayerViewControllerDelegate {
    func didDismiss() {
        getPlayer()?.play()
    }
    
    func getVideoView() -> MADVideoView {
        return videoView
    }
    
    func getControlsView() -> MADVideoControlsView {
        return controlsView
    }
}
