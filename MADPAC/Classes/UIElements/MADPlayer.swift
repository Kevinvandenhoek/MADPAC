//
//  MADPlayer.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 29/07/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import AVFoundation

class MADPlayer: AVPlayer {
    
    let video: MADVideo?
    var itemCallback: ((AVPlayerItem) -> Void)?
    
    init(from post: MADPost) {
        video = MADVideo(from: post)
        super.init()
        open(video)
    }
    
    private func open(_ video: MADVideo?) {
        guard let video = video else { return }
        YoutubeHelper.shared.getYoutube(url: video.url) { [weak self] (videoUrl) in
            DispatchQueue.main.async { [weak self] in
                let item = AVPlayerItem(url: videoUrl)
                self?.itemCallback?(item)
                self?.replaceCurrentItem(with: item)
            }
        }
    }
    
    func getCurrentItem(callback: @escaping (AVPlayerItem) -> Void) {
        if let item = self.currentItem {
            callback(item)
        } else {
            self.itemCallback = callback
        }
    }
}
