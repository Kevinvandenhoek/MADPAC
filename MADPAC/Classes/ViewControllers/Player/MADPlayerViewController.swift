//
//  MADPlayerViewController.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 29/10/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import AVKit

protocol MADPlayerViewControllerDelegate: AnyObject {
    func didDismiss()
    func getVideoView() -> MADVideoView
    func getControlsView() -> MADVideoControlsView
}

class MADPlayerViewController: AVPlayerViewController, AudioControllerPage {
    
    var videoView: MADVideoView? { return customDelegate?.getVideoView() }
    var controlsView: MADVideoControlsView? { return customDelegate?.getControlsView() }
    
    var audioObserver: NSKeyValueObservation?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    weak var customDelegate: MADPlayerViewControllerDelegate?
    
    init(player: AVPlayer?, delegate: MADPlayerViewControllerDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.customDelegate = delegate
        self.player = player
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard audioObserver == nil else { return }
        audioObserver = AVAudioSession.sharedInstance().observe( \.outputVolume ) { [weak self] (av, _) in
            guard let `self` = self else { return }
            self.updateForVolume(av.outputVolume)
            UserPreferences.session.muteVideo = av.outputVolume == 0
        }
        videoView?.playbackMode = UserPreferences.session.muteVideo ? .silent : .normal
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        customDelegate?.didDismiss()
        
        audioObserver?.invalidate()
        audioObserver = nil
    }
    
    deinit {
        print("Deinit \(String(describing: self))")
        audioObserver?.invalidate()
        audioObserver = nil
    }
}
