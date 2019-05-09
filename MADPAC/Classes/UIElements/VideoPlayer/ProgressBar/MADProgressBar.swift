//
//  MADProgressBar.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 22/07/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit

class MADProgressBar: MADView {
    
    let backTrack = MADView()
    let fillTrack = MADView()
    
    private(set) var progress: CGFloat = 0
    
    override func setup() {
        super.setup()
        
        addSubview(backTrack)
        backTrack.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        
        addSubview(fillTrack)
        fillTrack.backgroundColor = UIColor.MAD.hotPink
        updateFrames()
    }
    
    func displayHighlight(_ highlight: Bool ) {
        if highlight {
            fillTrack.backgroundColor = UIColor.MAD.hotPink
        } else {
            fillTrack.backgroundColor = UIColor.MAD.white.withAlphaComponent(0.3)
        }
    }
    
    override var frame: CGRect {
        didSet {
            updateFrames()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateFrames()
    }
    
    private func updateFrames() {
        backTrack.frame = bounds
        fillTrack.frame = CGRect(x: 0, y: 0, width: bounds.width * progress, height: bounds.height)
    }
    
    func updateProgress(_ newProgress: CGFloat) {
        self.progress = max(min(1, newProgress), 0)
        updateFrames()
    }
    
}
