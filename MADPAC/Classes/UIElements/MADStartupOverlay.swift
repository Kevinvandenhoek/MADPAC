//
//  MADStartupOverlay.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 14/07/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import EasyPeasy

class MADStartupOverlay: MADView {
    
    let imageView = UIImageView(image: #imageLiteral(resourceName: "logo_madpac").withRenderingMode(.alwaysTemplate))
    let imageViewMask = MADView()
    let backgroundView = MADView()
    
    override func setup() {
        super.setup()
        
        guard let imageSize = imageView.image?.size else { return }
        
        addSubview(backgroundView)
        backgroundView.easy.layout([Edges()])
        backgroundView.backgroundColor = UIColor.MAD.offWhite
        
        addSubview(imageView)
        imageView.tintColor = UIColor.black // this is the non template image color
        imageView.contentMode = .center
        imageView.easy.layout([Width(imageSize.width), Height(imageSize.height), Center()])
        
        addSubview(imageViewMask)
        imageViewMask.backgroundColor = UIColor.white
        imageViewMask.frame = imageView.frame
        imageView.mask = imageViewMask
    }
    
    func displayAdjustedColors() {
        backgroundView.backgroundColor = UIColor.MAD.UIElements.pageBackground
        imageView.tintColor = UIColor.MAD.UIElements.logoColor
    }
    
    func animateToAdjustedTint(completion: @escaping (Bool) -> Void) {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.backgroundView.backgroundColor = UIColor.MAD.UIElements.pageBackground
            self?.imageView.tintColor = UIColor.MAD.UIElements.logoColor
        }) { (completed) in
            completion(completed)
        }
    }
    
    func fadeOut(completion: @escaping (Bool) -> Void) {
        UIView.animate(withDuration: 0.6, animations: { [weak self] in
            guard let `self` = self else { return }
            self.backgroundView.alpha = 0
            self.imageViewMask.frame = CGRect(x: self.imageView.frame.width, y: 0, width: 0, height: self.imageView.frame.height)
        }) { (completed) in
            completion(completed)
        }
    }
}
