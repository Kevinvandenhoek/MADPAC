//
//  AVPlayer+Extension.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 28/07/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import AVFoundation

extension AVPlayer {
    func isPlaying() -> Bool {
        return self.rate > 0 && self.currentItem != nil
    }
    
    func togglePlay() {
        if self.rate > 0 {
            self.pause()
        } else {
            self.play()
        }
    }
    
    func currentStreamURL() -> URL? {
        return ((self.currentItem?.asset) as? AVURLAsset)?.url
    }
}
