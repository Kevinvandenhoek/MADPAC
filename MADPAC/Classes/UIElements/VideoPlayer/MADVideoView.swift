//
//  MADPlayerView.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 30/05/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

protocol MADVideoViewDelegate: AnyObject {
    func playbackStatusChanged(to status: MADVideoView.PlaybackStatus)
    func assetStatusChanged(to status: MADVideoView.AssetStatus)
    func handlePeriodicUpdating(for player: AVPlayer)
    func didFinishPlaying()
}

class MADVideoView : UIView{
    
    enum PlaybackStatus {
        case playing
        case stopped
        case loading
        case noAsset
    }
    
    enum AssetStatus {
        case readyToPlay
        case failed
        case noAsset
    }
    
    enum PlaybackMode {
        case silent
        case normal
    }
    
    private(set) var playbackStatus: PlaybackStatus = .stopped { didSet { delegate?.playbackStatusChanged(to: playbackStatus) } }
    private(set) var assetStatus: AssetStatus = .noAsset { didSet { delegate?.assetStatusChanged(to: assetStatus) } }
    var playbackMode: PlaybackMode = .silent { didSet { updatePlayerForPlaybackMode() } }
    
    var isObservingCurrentItem: Bool = false
    
    var currentVideo: MADVideo?
    weak var delegate: MADVideoViewDelegate?
    private let useAVPlayerPool: Bool
    
    private var timeObserverToken: Any?
    
    var player: MADPlayer? {
        get {
            return playerLayer.player as? MADPlayer
        }
        set {
            playerLayer.player = newValue
        }
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    init(useAVPlayerPool: Bool) {
        self.useAVPlayerPool = useAVPlayerPool
        super.init(frame: CGRect.zero)
        setup()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let player = object as? AVPlayer, player == self.player {
            if keyPath == "status" {
                switch player.status {
                case .readyToPlay:
                    self.assetStatus = .readyToPlay
                    if player.rate != 0 {
                        self.playbackStatus = .playing
                    }
                case .failed:
                    self.assetStatus = .failed
                case .unknown:
                    self.assetStatus = .failed
                }
            } else if keyPath == "rate" {
                if player.rate > 0 {
                    if player.status == .readyToPlay {
                        playbackStatus = .playing
                    } else {
                        playbackStatus = .loading
                    }
                } else {
                    playbackStatus = .stopped
                }
            }
        }
    }
    
    deinit {
        if isObservingCurrentItem, let playerItem = player?.currentItem {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
            isObservingCurrentItem = false
        }
    }
}


// View setup
extension MADVideoView {
    
    func setup() {
        playerLayer.videoGravity = .resizeAspectFill
    }
    
    private func updatePlayerForPlaybackMode() {
        player?.isMuted = playbackMode == .silent ? true : false
    }
    
    private func addPeriodicTimeObserver(for player: AVPlayer?) {
        guard let player = player, timeObserverToken == nil else { return }
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: MADConstants.videoUpdateRate, preferredTimescale: timeScale)
        
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] time in
            guard let `self` = self else { return }
            self.delegate?.handlePeriodicUpdating(for: player)
        }
    }
}

// View updating
extension MADVideoView {
    
    func update(with post: MADPost) {
        if player != nil {
            releasePlayer()
        }
        
        currentVideo = MADVideo(from: post)
        player = useAVPlayerPool ? MADPlayerManager.shared.getPlayer(for: post) : MADPlayer(from: post)
        player?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        player?.addObserver(self, forKeyPath: "rate", options: .new, context: nil)
        player?.getCurrentItem(callback: { [weak self] (playerItem) in
            guard let `self` = self else { return }
            NotificationCenter.default.addObserver(self, selector: #selector(self.didFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
            self.isObservingCurrentItem = true
        })
        addPeriodicTimeObserver(for: player)
        updatePlayerForPlaybackMode()
    }
    
    func releasePlayer() {
        if isObservingCurrentItem, let playerItem = player?.currentItem {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
            isObservingCurrentItem = false
        }
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
        }
        player?.removeObserver(self, forKeyPath: "status")
        player?.removeObserver(self, forKeyPath: "rate")
        player?.pause()
        player = nil
        timeObserverToken = nil
        playbackStatus = .stopped
    }
    
    func seek(to percentage: CGFloat) {
        guard let item = player?.currentItem, item.duration.seconds.isFinite else { return }
        let frameRate = Double(item.asset.tracks.first?.nominalFrameRate ?? 30)
        let duration = item.duration.seconds
        let currentTime = item.currentTime().seconds
        let requestedTime = duration * Double(percentage)
        let steps = Int((requestedTime - currentTime) * frameRate)
        player?.currentItem?.step(byCount: steps)
    }
}

// Status handling
extension MADVideoView {
    @objc private func didFinishPlaying() {
        delegate?.didFinishPlaying()
    }
}
