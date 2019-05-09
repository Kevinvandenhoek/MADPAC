//
//  AudioControllerPage.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 31/07/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import Foundation

enum PlaybackMode {
    case silent
    case normal
}

protocol AudioControllerPage {
    var videoView: MADVideoView? { get }
    var controlsView: MADVideoControlsView? { get }
    
    func updateForVolume(_ volume: Float)
}

extension AudioControllerPage {
    func updateForVolume(_ volume: Float) {
        let mute = volume == 0
        videoView?.playbackMode = mute ? .silent : .normal
        MediaSessionHelper.shared.setMediaType(to: mute ? .silent : .audio)
        controlsView?.updateMuteIcon(volume: volume)
    }
}
