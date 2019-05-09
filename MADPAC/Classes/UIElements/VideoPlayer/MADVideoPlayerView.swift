//
//  MADVideoPlayerView.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 15/07/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import EasyPeasy
import AVFoundation

protocol MADVideoPlayerDelegate: AnyObject {
    func playbackStatusChanged(to status: MADVideoView.PlaybackStatus)
    func didFinishPlaying()
    //func getVC() -> UIViewController
}

struct MADVideo: Equatable {
    let url: String
    let title: String
    let type: MADVideoType
    let thumbnailUrl: String?
    let controlsView: MADVideoControlsView = MADVideoControlsView(frame: CGRect.zero)
    
    init?(from post: MADPost) {
        guard let url = post.videoUrl, let type = post.videoType, let title = post.title else { return nil }
        self.url = url
        self.type = type
        self.title = title
        self.thumbnailUrl = post.thumbnailImageUrl
    }
    
    static func == (lhs: MADVideo, rhs: MADVideo) -> Bool {
        return lhs.title == rhs.title && lhs.url == rhs.url
    }
}

class MADVideoPlayerView: MADView {
    
    let thumbnailView: MADImageView = MADImageView()
    var videoView: MADVideoView = MADVideoView(useAVPlayerPool: false)
    var currentVideo: MADVideo? { return videoView.currentVideo }
    let controlsView: MADVideoControlsView = MADVideoControlsView()
    
    weak var delegate: MADVideoPlayerDelegate?
    
    override func setup() {
        super.setup()
        
        addSubview(thumbnailView)
        thumbnailView.easy.layout([Edges()])
        
        self.backgroundColor = UIColor.MAD.UIElements.cellBackground
        addSubview(videoView)
        videoView.easy.layout([Edges()])
        videoView.delegate = self
        videoView.alpha = 0
        
        addSubview(controlsView)
        controlsView.easy.layout([Edges()])
        controlsView.delegate = self
        
        showVideoView(false, animated: false)
    }
    
    func update(with post: MADPost, play: Bool = true) {
        // TODO: Start playback
        videoView.update(with: post)
        videoView.alpha = 0
        if play {
            videoView.player?.play()
        }
        thumbnailView.setImage(with: post.imageUrl)
    }
    
    private func showVideoView(_ show: Bool, animated: Bool) {
        UIView.animate(withDuration: animated ? 0.2 : 0) { [weak self] in
            self?.videoView.alpha = show ? 1 : 0
        }
    }
}

extension MADVideoPlayerView: ColorUpdatable {
    
    func updateColors() {
        thumbnailView.updateColors()
    }
}

extension MADVideoPlayerView: MADVideoViewDelegate {
    
    func didFinishPlaying() {
        delegate?.didFinishPlaying()
    }
    
    func playbackStatusChanged(to status: MADVideoView.PlaybackStatus) {
        delegate?.playbackStatusChanged(to: status)
        controlsView.handlePlaybackStatus(status)
        if status == .playing {
            showVideoView(true, animated: true)
            controlsView.playButton.hide(animated: true, completion: { [weak self] (completed) in
                if completed {
                    self?.controlsView.playButton.display(state: status)
                }
            })
        } else {
            guard !controlsView.userIsSeeking else { return }
            controlsView.playButton.display(state: status)
            controlsView.playButton.show(animated: true)
            if status == .loading {
                showVideoView(false, animated: false)
            }
        }
    }
    
    func assetStatusChanged(to status: MADVideoView.AssetStatus) {
        // TODO
    }
    
    func handlePeriodicUpdating(for player: AVPlayer) {
        controlsView.handlePeriodicUpdating(for: player)
    }
}

extension MADVideoPlayerView: MADVideoControlsViewDelegate {
    
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
    
    func getPlayButton() -> MADPlayButton? {
        return nil
    }
    
    func didTapPlay() {
        videoView.player?.togglePlay()
    }
    
    func didTapMaximize() {
        let videoVC = MADPlayerViewController(player: self.getPlayer(), delegate: self)
        self.parentViewController?.present(videoVC, animated: true)
    }
    
    func didTapVolume() {
        // TODO: Implement
    }
    
    func didRequestSeek(to percentage: CGFloat) {
        videoView.seek(to: percentage)
    }
}

extension MADVideoPlayerView: MADPlayerViewControllerDelegate {
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
