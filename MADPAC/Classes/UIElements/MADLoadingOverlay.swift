//
//  MADLoadingOverlay.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 14/07/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import EasyPeasy

class MADLoadingOverlay: MADView, ColorUpdatable {
    
    let blurView = UIVisualEffectView(effect: nil)
    var blurEffect: UIBlurEffect { return UIBlurEffect(style: UserPreferences.darkMode ? .dark : .extraLight) }
    let noEffect = UIVisualEffect()
    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var indicatorOffsetY: CGFloat = 0 { didSet { updateActivityViewOffset() } }
    
    override func setup() {
        super.setup()
        
        addSubview(blurView)
        blurView.easy.layout([Edges()])
        blurView.effect = noEffect
        
        addSubview(activityIndicatorView)
        activityIndicatorView.easy.layout([Size(80), CenterX(), CenterY(self.indicatorOffsetY)])
        activityIndicatorView.alpha = 0
        activityIndicatorView.color = UIColor.MAD.UIElements.primaryText
    }
    
    func startLoading() {
        activityIndicatorView.startAnimating()
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let `self` = self else { return }
            self.blurView.effect = self.blurEffect
            self.activityIndicatorView.alpha = 1
        })
    }
    
    func stopLoading(completion: @escaping (Bool) -> Void) {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let `self` = self else { return }
            self.blurView.effect = self.noEffect
            self.activityIndicatorView.alpha = 0
        }) { [weak self] (completed) in
            guard let `self` = self else { return }
            self.activityIndicatorView.stopAnimating()
            completion(completed)
        }
    }
    
    func updateActivityViewOffset() {
        activityIndicatorView.easy.layout([CenterY(self.indicatorOffsetY)])
    }
    
    func updateColors() {
        activityIndicatorView.color = UIColor.MAD.UIElements.primaryText
        if blurView.effect != noEffect {
            blurView.effect = blurEffect
        }
    }
}
