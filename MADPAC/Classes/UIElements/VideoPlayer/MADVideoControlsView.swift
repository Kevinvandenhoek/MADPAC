//
//  MADVideoControlsView.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 22/07/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import EasyPeasy
import AVFoundation

protocol MADVideoControlsViewDelegate: AnyObject {
    func getPlayButton() -> MADPlayButton?
    
    func didTapPlay()
    func didTapMaximize()
    func didTapVolume()
    func didRequestSeek(to percentage: CGFloat)
    func videoIsPlaying() -> Bool
    func finishSeek(wasPlaying: Bool)
    func getPlayer() -> AVPlayer?
}

class MADVideoControlsView: MADView {
    
    weak var currentItem: AVPlayerItem?
    
    let backgroundGestureView = MADView()
    let seekView = MADSeekView()
    var playButton = MADPlayButton()
    let progressBar = MADProgressBar()
    let currentDurationLabel = MADLabel(style: .videoTime)
    let totalDurationLabel = MADLabel(style: .videoTime)
    let fullscreenButton = MADButton()
    let bottomGradient = MADImageView(image: #imageLiteral(resourceName: "gradient_video_bottom"))
    let topGradient = MADImageView(image: #imageLiteral(resourceName: "gradient_video_top"))
    let volumeView = MADVolumeView()
    let titleLabel = MADLabel(style: .videoTitle)
    
    var currentPlayButton: MADPlayButton { return delegate?.getPlayButton() ?? playButton }
    
    private var controlsVisible: Bool = true
    
    let basePlayOffset: CGFloat = 0
    
    let autoHideTime: Double = 3.0
    var autoHideTimer: Double = 0.0
    
    private var startPanLocation: CGPoint?
    private var startPanProgress: CGFloat?
    private var isSeeking: Bool = false
    private var wasPlayingBeforeSeeking: Bool = false
    var userIsSeeking: Bool { return isSeeking }
    
    weak var delegate: MADVideoControlsViewDelegate? {
        didSet {
            updatePlayButtonVisibility()
        }
    }
    
    override func setup() {
        super.setup()
        
        layoutViews()
        setupViews()
    }
    
    func setPlayButtonOffset(_ newOffset: CGFloat) {
        playButton.easy.layout(CenterY(newOffset))
    }
    
    func restorePlayOffset() {
        playButton.easy.layout(CenterY(basePlayOffset))
    }
    
    private func updatePlayButtonVisibility() {
        if delegate?.getPlayButton() != nil {
            playButton.isHidden = true
        } else {
            playButton.isHidden = false
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews {
            if subview.isUserInteractionEnabled && !subview.isHidden && subview.alpha > 0 && subview.point(inside: convert(point, to: subview), with: event) {
                return true
            }
        }
        return false
    }
    
    @objc func didPanBackgroundView(sender: UIPanGestureRecognizer) {
        handleScrubbing(gesture: sender)
    }
    
    @objc func didTapBackgroundView() {
        // TODO: Toggle play
        toggleControls()
    }
    
    @objc func didTapVolume() {
        delegate?.didTapVolume()
    }
    
    @objc func didTapMaximize() {
        delegate?.didTapMaximize()
    }
    
    @objc func didTapPlay() {
        delegate?.didTapPlay()
    }
    
    func updateMuteIcon(volume: Float) {
        volumeView.update(with: volume)
        flashVolumeView()
    }
    
    func handlePlaybackStatus(_ status: MADVideoView.PlaybackStatus) {
        currentPlayButton.display(state: status)
        if status == .playing {
            hideControls(animated: true)
        }
    }
}

// View updating
extension MADVideoControlsView {
    
    func handlePeriodicUpdating(for player: AVPlayer) {
        guard let duration = player.currentItem?.duration,
            let currentTime = player.currentItem?.currentTime(),
            duration.seconds.isFinite, currentTime.seconds.isFinite else { return }
        
        func getTimeString(for duration: Double) -> String {
            let seconds: Int = Int(Int(duration) % 60)
            let minutes: Int = Int(Int(duration / 60) % 60)
            var mins: String = minutes.description
            let hours = Int(duration / 3600)
            if (hours > 0 && minutes < 10) {
                mins = "0" + minutes.description
            }
            
            let minuteString = mins
            let hourString = (hours > 0 ? hours.description + ":" : "")
            let secondsPrefix = (seconds.description.count < 2 ? "0" : "")
            let secondsString = seconds.description
            let timeText = hourString + minuteString + ":" + secondsPrefix + secondsString
            return timeText
        }
        
        autoHideTimerTick()
        
        totalDurationLabel.text = getTimeString(for: duration.seconds)
        currentDurationLabel.text = getTimeString(for: currentTime.seconds)

        if !isSeeking {
            progressBar.updateProgress(CGFloat(currentTime.seconds / duration.seconds))
        }
    }
    
    func updateFor(post: MADPost) {
        titleLabel.text = post.title
        progressBar.updateProgress(0)
        currentDurationLabel.text = nil
        totalDurationLabel.text = nil
    }
    
    func showControls(animated: Bool) {
        guard controlsVisible != true, !isSeeking else { return }
        autoHideTimer = 0
        controlsVisible = true
        // TODO: Maybe update play button state
        if animated {
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [.allowUserInteraction], animations: { [weak self] in
                guard let `self` = self else { return }
                self.moveControlsToPosition(hidden: false)
            })
        } else {
            moveControlsToPosition(hidden: false)
        }
    }
    
    func hideControls(animated: Bool, duration: Double = 0.7, ignoringPlayButton: Bool = false) {
        guard controlsVisible != false, !isSeeking else { return }
        controlsVisible = false
        if animated {
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [.allowUserInteraction], animations: { [weak self] in
                guard let `self` = self else { return }
                self.moveControlsToPosition(hidden: true)
            })
        } else {
            moveControlsToPosition(hidden: true, ignoringPlayButton: ignoringPlayButton)
        }
    }
    
    func toggleControls() {
        if controlsVisible {
            hideControls(animated: true)
        } else {
            showControls(animated: true)
        }
    }
    
    private func autoHideTimerTick() {
        guard controlsVisible else {
            autoHideTimer = 0
            return
        }
        autoHideTimer += MADConstants.videoUpdateRate
        
        if autoHideTimer > autoHideTime {
            autoHideTimer = 0
            hideControls(animated: true, duration: 1.4)
        }
    }
    
    func flashVolumeView() {
        volumeView.alpha = 1
        UIView.animate(withDuration: 0.5, delay: 1, options: [.curveEaseInOut], animations: { [weak self] in
            self?.volumeView.alpha = 0
        })
    }
    
    func setProgressBarHighlighted(_ highlighted: Bool, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let `self` = self else { return }
                self.progressBar.easy.layout([Height(highlighted ? 3 : 2)])
                self.progressBar.displayHighlight(highlighted)
                self.progressBar.alpha = highlighted ? 1 : 0.6
                self.layoutIfNeeded()
            }
        } else {
            self.progressBar.easy.layout([Height(highlighted ? 3 : 2)])
            self.progressBar.displayHighlight(highlighted)
            self.progressBar.alpha = highlighted ? 1 : 0.6
            layoutIfNeeded()
        }
    }
}

// View setup
extension MADVideoControlsView {
    
    func setupViews() {
        backgroundGestureView.isUserInteractionEnabled = true
        backgroundGestureView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapBackgroundView)))
        backgroundGestureView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didPanBackgroundView)))
        
        bottomGradient.isUserInteractionEnabled = false
        topGradient.isUserInteractionEnabled = false
        
        fullscreenButton.image = #imageLiteral(resourceName: "icon_maximize").withRenderingMode(.alwaysTemplate)
        fullscreenButton.tintColor = UIColor.MAD.offWhite
        fullscreenButton.addTarget(self, action: #selector(didTapMaximize), for: .touchUpInside)
        fullscreenButton.tintColor = UIColor.MAD.offWhite
        
        currentDurationLabel.textColor = UIColor.MAD.offWhite
        totalDurationLabel.textColor = UIColor.MAD.offWhite.withAlphaComponent(0.7)
        
        progressBar.updateProgress(0)
        
        volumeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapVolume)))
        
        titleLabel.numberOfLines = 2
        
        playButton.addTarget(self, action: #selector(didTapPlay), for: .touchUpInside)
    }
    
    func layoutViews() {
        addSubview(backgroundGestureView)
        backgroundGestureView.easy.layout([Edges()])
        
        addSubview(bottomGradient)
        bottomGradient.easy.layout([Right(), Left(), Bottom(), Height(bottomGradient.image?.size.height ?? 0)])
        
        addSubview(topGradient)
        topGradient.easy.layout([Right(), Left(), Top(), Height(topGradient.image?.size.height ?? 0)])
        
        addSubview(seekView)
        seekView.easy.layout([Edges()])
        
        addSubview(playButton)
        playButton.easy.layout([Size(100), CenterY(basePlayOffset), CenterX()])
        
        addSubview(fullscreenButton)
        fullscreenButton.easy.layout([Right(5), Width(57), Height(57), Bottom(2)])
        
        addSubview(currentDurationLabel)
        currentDurationLabel.easy.layout([Left(21), Bottom(21), Height(17)])
        
        addSubview(totalDurationLabel)
        totalDurationLabel.easy.layout([Right().to(fullscreenButton, .left), Bottom(21), Height(17)])
        
        addSubview(progressBar)
        progressBar.easy.layout([Left(), Bottom(), Right(), Height(3)])
        
        addSubview(titleLabel)
        titleLabel.easy.layout([Left(21), Top(21), Height(>=20)])
        
        addSubview(volumeView)
        volumeView.easy.layout([Size(60), Right(), CenterY().to(titleLabel, .centerY)])
        titleLabel.easy.layout([Right().to(volumeView)])
    }
    
    private func moveControlsToPosition(hidden: Bool, ignoringPlayButton: Bool = false) {
        topGradient.alpha = hidden ? 0 : 1
        bottomGradient.alpha = hidden ? 0 : 1
        
        fullscreenButton.alpha = hidden ? 0 : 1
        
        currentDurationLabel.alpha = hidden ? 0 : 1
        totalDurationLabel.alpha = hidden ? 0 : 1
        volumeView.alpha = hidden ? 0 : 1
        titleLabel.alpha = hidden ? 0 : 1
        
        let normalTransform = CGAffineTransform.identity
        
        titleLabel.transform = hidden ? CGAffineTransform.identity.translatedBy(x: 0, y: -15) : normalTransform
        
        currentDurationLabel.transform = hidden ? CGAffineTransform.identity.translatedBy(x: -15, y: 0) : normalTransform
        totalDurationLabel.transform = hidden ? CGAffineTransform.identity.translatedBy(x: 15, y: 0) : normalTransform
        
        setProgressBarHighlighted(!hidden, animated: false)
        
        if !ignoringPlayButton {
            currentPlayButton.alpha = hidden ? 0 : 1
        }
    }
}

// Internal logic
extension MADVideoControlsView {
    
    func handleScrubbing(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .possible, .began:
            hideControls(animated: true)
            wasPlayingBeforeSeeking = delegate?.videoIsPlaying() == true
            isSeeking = true
            startPanLocation = gesture.location(in: self)
            setProgressBarHighlighted(true, animated: true)
            startPanProgress = progressBar.progress
        case .changed:
            guard let startPanLocation = startPanLocation, let startPanProgress = startPanProgress else { return }
            let delta = gesture.location(in: self).x - startPanLocation.x
            let percentage = delta / self.frame.width
            progressBar.updateProgress(startPanProgress + percentage)
            delegate?.didRequestSeek(to: progressBar.progress)
            if let duration = delegate?.getPlayer()?.currentItem?.duration.seconds, duration.isFinite {
                seekView.displaySeekDelta(seconds: duration * Double(percentage))
            }
        case .ended, .cancelled, .failed:
            isSeeking = false
            startPanLocation = nil
            if !controlsVisible {
                setProgressBarHighlighted(false, animated: true)
            }
            delegate?.finishSeek(wasPlaying: wasPlayingBeforeSeeking)
            if !wasPlayingBeforeSeeking {
                showControls(animated: true)
            }
            wasPlayingBeforeSeeking = false
            seekView.fadeOut()
        }
    }
}
