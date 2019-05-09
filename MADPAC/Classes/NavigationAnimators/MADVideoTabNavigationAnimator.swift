//
//  MADVideoTabNavigationAnimator.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 21/07/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import Foundation
import UIKit
import EasyPeasy

class MADVideoTabNavigationAnimator: NSObject, UIViewControllerAnimatedTransitioning, PopAnimator {
    
    let navigationController: MADNavigationViewController
    var duration: TimeInterval
    var isPresenting: Bool
    var videoTopView: MADVideoTopView
    let parallaxDistance: CGFloat = 150
    var isPop: Bool = false
    
    init(duration: CGFloat, isPresenting: Bool, videoTopView: MADVideoTopView, navigationController: MADNavigationViewController) {
        self.duration = Double(duration)
        self.isPresenting = isPresenting
        self.videoTopView = videoTopView
        self.navigationController = navigationController
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        guard let toVc = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let fromVc = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let fromView = fromVc.view,
            let toView = toVc.view else {
                return
        }
        
        let blurEffect = UIBlurEffect(style: (UserPreferences.darkMode ? .dark : .extraLight))
        let startEffect = self.isPresenting ? nil : blurEffect
        let endEffect = self.isPresenting ? blurEffect : nil
        let blurView = UIVisualEffectView(effect: startEffect)
        
        (fromVc as? TopBarPage)?.topBarPageDelegate = nil
        if self.isPresenting {
            container.addSubview(toView)
            container.insertSubview(blurView, belowSubview: toView)
            fromView.transform = CGAffineTransform.identity
            fromView.frame = container.bounds
            toView.transform = CGAffineTransform.identity.translatedBy(x: container.frame.width, y: 0)
            toView.alpha = 0
        } else {
            container.insertSubview(blurView, belowSubview: fromView)
            container.insertSubview(toView, belowSubview: blurView)
            toView.frame = container.bounds
            toView.transform = CGAffineTransform.identity.translatedBy(x: -parallaxDistance, y: 0)
        }
        
        blurView.frame = container.frame
        toView.layoutIfNeeded()
        
        // Standard animation
        UIView.animate(withDuration: self.duration, delay: 0, options: !isPop ? [.curveEaseInOut] : [.curveLinear], animations: { [weak self] in
            guard let `self` = self else { return }
            doAnimations()
        }) { [weak self] (completed) in
            guard let `self` = self else { return }
            doCompletion(completed)
        }
        
        func doAnimations() {
            blurView.effect = endEffect
            videoTopView.updateInTransition(for: isPresenting)
            navigationController.updateBackButtonInTransition(for: toVc)
            if self.isPresenting {
                fromVc.tabBarController?.hideTabBar(animated: false)
                toView.transform = CGAffineTransform.identity
                fromView.transform = CGAffineTransform.identity.translatedBy(x: -parallaxDistance, y: 0)
                toView.alpha = 1
            } else {
                toVc.view.transform = CGAffineTransform.identity
                toVc.tabBarController?.showTabBar(animated: false)
                fromView.transform = CGAffineTransform.identity.translatedBy(x: container.frame.width, y: 0)
            }
        }
        
        func doCompletion(_ completed: Bool) {
            toVc.view.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            toVc.view.transform = CGAffineTransform.identity
            fromVc.view.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            fromVc.view.transform = CGAffineTransform.identity
            fromView.alpha = 1
            toView.alpha = 1
            
            let transitionCompleted = !transitionContext.transitionWasCancelled
            if transitionCompleted {
                navigationController.handleTopPage(for: toVc)
                navigationController.handleBackButton(for: toVc, animated: true)
            } else { // TODO: Restore the view to the giver
                (fromVc as? TopBarPage)?.topBarPageDelegate = navigationController
                navigationController.handleTopPage(for: fromVc)
                navigationController.handleBackButton(for: fromVc, animated: true)
            }
            
            blurView.effect = nil
            blurView.removeFromSuperview()
            transitionContext.completeTransition(transitionCompleted)
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
}
