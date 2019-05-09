//
//  MADSearchNavigationAnimator.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 04/08/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import EasyPeasy

class MADSearchNavigationAnimator: NSObject, UIViewControllerAnimatedTransitioning, PopAnimator {
    
    var isPop: Bool = false
    var duration: TimeInterval
    var isPresenting: Bool
    var navigationController: MADNavigationViewController
    
    init(duration: CGFloat, isPresenting: Bool, navigationController: MADNavigationViewController) {
        self.duration = Double(duration)
        self.isPresenting = isPresenting
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
        
        let newTopBarPage = toVc as? TopBarPage
        (fromVc as? TopBarPage)?.topBarPageDelegate = nil
        if self.isPresenting {
            container.addSubview(toView)
            container.insertSubview(blurView, belowSubview: toView)
            fromView.transform = CGAffineTransform.identity
            fromView.frame = container.bounds
        } else {
            navigationController.handleTopPage(for: toVc)
            container.insertSubview(blurView, belowSubview: fromView)
            container.insertSubview(toView, belowSubview: blurView)
            toView.transform = CGAffineTransform.identity
            toView.frame = container.bounds
        }
        
        blurView.frame = navigationController.view.frame
        toView.layoutIfNeeded()
        if let searchVC = toVc as? MADSearchViewController {
            searchVC.prepareForTransition(presenting: isPresenting, isTargetVc: true, transitionProperties: TransitionProperties.zero)
        } else if let searchVC = fromVc as? MADSearchViewController {
            searchVC.prepareForTransition(presenting: isPresenting, isTargetVc: false, transitionProperties: TransitionProperties.zero)
        }
        
        // Standard animation
        UIView.animate(withDuration: duration + 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [.allowUserInteraction], animations: { [weak self] in
            guard let `self` = self else { return }
            doAnimations()
        }) { [weak self] (completed) in
            guard let `self` = self else { return }
            doCompletion(completed)
        }
        
        func doAnimations() {
            blurView.effect = endEffect
            navigationController.showTitle((toVc as? MADBaseViewController)?.hidesNavigationBarTitle == false)
            navigationController.updateBackButtonInTransition(for: toVc)
            navigationController.updateSearchVisiblity(for: toVc)
            
            if let searchVC = toVc as? MADSearchViewController {
                searchVC.animateInTransition(presenting: isPresenting, isTargetVc: true)
            } else if let searchVC = fromVc as? MADSearchViewController {
                searchVC.animateInTransition(presenting: isPresenting, isTargetVc: false)
            }
            
            if self.isPresenting {
                if newTopBarPage == nil {
                    navigationController.hideTopBar()
                }
                navigationController.showSearchBar(true)
            } else {
                toVc.view.transform = CGAffineTransform.identity
                toVc.tabBarController?.showTabBar(animated: false)
                navigationController.updateTopBarOffset(to: 0)
                navigationController.showSearchBar(false)
            }
        }
        
        func doCompletion(_ completed: Bool) {
            toVc.view.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            toVc.view.transform = CGAffineTransform.identity
            fromVc.view.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            fromVc.view.transform = CGAffineTransform.identity
            
            let transitionCompleted = !transitionContext.transitionWasCancelled
            if transitionCompleted {
                navigationController.handleTopPage(for: toVc)
                navigationController.handleBackButton(for: toVc, animated: true)
            } else { // TODO: Restore the view to the giver
                (fromVc as? TopBarPage)?.topBarPageDelegate = navigationController
                navigationController.showTitle((fromVc as? MADBaseViewController)?.hidesNavigationBarTitle == false)
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

