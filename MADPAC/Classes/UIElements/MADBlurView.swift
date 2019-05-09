//
//  MADBlurView.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 15/07/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import EasyPeasy

class MADBlurView: MADView {
    
    let blurView = UIVisualEffectView(effect: nil)
    let blurEffect = UIBlurEffect(style: .dark)
    
    override func setup() {
        super.setup()
        
        addSubview(blurView)
        blurView.easy.layout([Edges()])
    }
    
    func setBlur(amount: Double) {
        blurView.effect = nil
        let animator = UIViewPropertyAnimator(duration: 1, curve: .linear)
        animator.addAnimations { [weak self] in
            guard let `self` = self else { return }
            self.blurView.effect = self.blurEffect
        }
        animator.startAnimation()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + amount) {
            animator.fractionComplete = CGFloat(amount)
            animator.stopAnimation(true)
            animator.finishAnimation(at: UIViewAnimatingPosition.current)
        }
    }
}
