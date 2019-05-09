//
//  MADVolumeView.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 23/07/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import EasyPeasy

class MADVolumeView: MADView {
    
    let imageView: UIImageView = UIImageView(image: UIImage(named: "icon_speaker_mute")!.withRenderingMode(.alwaysTemplate))
    
    override func setup() {
        super.setup()
        
        clipsToBounds = false
        
        addSubview(imageView)
        imageView.contentMode = .center
        imageView.easy.layout([Size(20), Center()])
        imageView.tintColor = UIColor.MAD.offWhite
    }
    
    func update(with volume: Float) {
        if volume > 0.66 {
            imageView.image = UIImage(named: "icon_speaker_high")
        } else if volume > 0.33 {
            imageView.image = UIImage(named: "icon_speaker_medium")
        } else if volume > 0 {
            imageView.image = UIImage(named: "icon_speaker_low")
        } else {
            imageView.image = UIImage(named: "icon_speaker_mute")
        }
    }
}
