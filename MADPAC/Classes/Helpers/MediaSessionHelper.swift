//
//  MediaSessionHelper.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 31/07/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import AVFoundation

class MediaSessionHelper {
    
    static var shared: MediaSessionHelper = { return MediaSessionHelper() }()
    
    private var mediaType: MediaType?
    
    enum MediaType {
        case silent
        case audio
    }
    
    func setMediaType(to mediaType: MediaType) {
        guard mediaType != self.mediaType else { return }
        switch mediaType {
        case .silent:
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategorySoloAmbient)
            //try? AVAudioSession.sharedInstance().setActive(false)
        case .audio:
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            //try? AVAudioSession.sharedInstance().setActive(true)
        }
    }
    
}
