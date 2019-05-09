//
//  MADRoundView.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 14/07/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit

class MADRoundView: MADView {
    
    override var frame: CGRect {
        didSet {
            updateFrame()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateFrame()
    }
    
    func updateFrame() {
        self.layer.cornerRadius = min(frame.width, frame.height) / 2
    }
}
