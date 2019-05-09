//
//  MADNavigationAnimator.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 15/07/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import EasyPeasy

class MADTransitioningViewNavigationAnimator: NSObject, UIViewControllerAnimatedTransitioning, PopAnimator {
    
    var isPop: Bool = false
    var duration: TimeInterval
    var isPresenting: Bool
    var originRect: CGRect
    var targetRect: CGRect
    var transitioningView: UIView
    var receivingView: NavigationTransitioningView
    var givingView: NavigationTransitioningView
    var navigationController: MADNavigationViewController
    
    init(duration: CGFloat, isPresenting: Bool, originRect: CGRect, targetRect: CGRect, transitioningView: UIView,
         givingView: NavigationTransitioningView, receivingView: NavigationTransitioningView, navigationController: MADNavigationViewController) {
        self.duration = Double(duration)
        self.isPresenting = isPresenting
        self.originRect = originRect
        self.targetRect = targetRect
        self.givingView = givingView
        self.receivingView = receivingView
        self.transitioningView = transitioningView
        self.navigationController = navigationController
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        guard let toVc = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let toTransitioningVc = toVc as? NavigationTransitioningView,
            let fromVc = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let fromTransitioningVc = fromVc as? NavigationTransitioningView,
            let fromView = fromVc.view,
            let toView = toVc.view else {
            return
        }
        
        let blurEffect = UIBlurEffect(style: (UserPreferences.darkMode ? .dark : .extraLight))
        let startEffect = self.isPresenting ? nil : blurEffect
        let endEffect = self.isPresenting ? blurEffect : nil
        let blurView = UIVisualEffectView(effect: startEffect)
        let transitionViewContainer = MADView()
        
        var transitionProperties = TransitionProperties.zero
        var zoomedTransform = (CGAffineTransform.identity, CGPoint.zero)
        let newTopBarPage = toVc as? TopBarPage
        (fromVc as? TopBarPage)?.topBarPageDelegate = nil
        if self.isPresenting {
            container.addSubview(toView)
            container.insertSubview(blurView, belowSubview: toView)
            transitionProperties = getTransitionProperties(from: originRect, to: targetRect, for: transitioningView)
            zoomedTransform = getZoomedTransformAndAnchorPoint(for: fromView, originRect: originRect, targetRect: targetRect)
            fromView.layer.anchorPoint = zoomedTransform.1
            fromView.transform = CGAffineTransform.identity
            fromView.frame = container.bounds
        } else {
            navigationController.handleTopPage(for: toVc)
            container.insertSubview(blurView, belowSubview: fromView)
            container.insertSubview(toView, belowSubview: blurView)
            transitionProperties = getTransitionProperties(from: targetRect, to: originRect, for: transitioningView)
            zoomedTransform = getZoomedTransformAndAnchorPoint(for: toView, originRect: targetRect, targetRect: originRect)
            toView.layer.anchorPoint = zoomedTransform.1
            toView.transform = CGAffineTransform.identity
            toView.frame = container.bounds
            toView.transform = zoomedTransform.0
        }
        container.addSubview(transitionViewContainer)
        transitionViewContainer.frame = self.originRect
        transitionViewContainer.addSubview(transitioningView)
        transitionViewContainer.layer.cornerRadius = isPresenting ? MADPostsCollectionViewController.cellCornerRadius : 0
        transitioningView.easy.layout([Edges()])
        
        blurView.frame = navigationController.view.frame
        toView.layoutIfNeeded()
        
        (transitioningView as? NavigationTransitioningView)?.prepareForTransition(presenting: isPresenting, isTargetVc: false, transitionProperties: transitionProperties)
        fromTransitioningVc.prepareForTransition(presenting: isPresenting, isTargetVc: false, transitionProperties: transitionProperties)
        toTransitioningVc.prepareForTransition(presenting: isPresenting, isTargetVc: true, transitionProperties: transitionProperties)
        
        // Spring animation, probably buggy with interactive pop
//        UIView.animate(withDuration: self.duration + 0.2, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [.allowUserInteraction, .curveEaseInOut], animations: { [weak self] in
//            guard let `self` = self else { return }
//            doAnimations()
//        }) { [weak self] (completed) in
//            guard let `self` = self else { return }
//            doCompletion(completed)
//        }
        
        // Standard animation
        UIView.animate(withDuration: self.duration, delay: 0, options: [.curveEaseInOut], animations: { [weak self] in
            guard let `self` = self else { return }
            doAnimations()
        }) { [weak self] (completed) in
            guard let `self` = self else { return }
            doCompletion(completed)
        }
        
        func doAnimations() {
            blurView.effect = endEffect
            transitionViewContainer.frame = self.targetRect
            transitionViewContainer.layoutSubviews()
            self.transitioningView.layoutSubviews()
            fromTransitioningVc.animateInTransition(presenting: self.isPresenting, isTargetVc: false)
            toTransitioningVc.animateInTransition(presenting: self.isPresenting, isTargetVc: true)
            navigationController.showTitle((toVc as? MADBaseViewController)?.hidesNavigationBarTitle == false)
            transitionViewContainer.layer.cornerRadius = isPresenting ? 0 : MADPostsCollectionViewController.cellCornerRadius
            (transitioningView as? NavigationTransitioningView)?.animateInTransition(presenting: self.isPresenting, isTargetVc: false)
            navigationController.updateBackButtonInTransition(for: toVc)
            navigationController.updateSearchVisiblity(for: toVc)
            if self.isPresenting {
                if newTopBarPage == nil {
                    navigationController.hideTopBar()
                }
                fromView.transform = zoomedTransform.0
            } else {
                toVc.view.transform = CGAffineTransform.identity
                toVc.tabBarController?.showTabBar(animated: false)
                navigationController.updateTopBarOffset(to: 0)
            }
        }
        
        func doCompletion(_ completed: Bool) {
            toVc.view.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            toVc.view.transform = CGAffineTransform.identity
            fromVc.view.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            fromVc.view.transform = CGAffineTransform.identity
            
            let transitionCompleted = !transitionContext.transitionWasCancelled
            if transitionCompleted {
                self.receivingView.receive(transitionedView: self.transitioningView)
                navigationController.handleTopPage(for: toVc)
                navigationController.handleBackButton(for: toVc, animated: true)
            } else { // TODO: Restore the view to the giver
                (fromVc as? TopBarPage)?.topBarPageDelegate = navigationController
                self.givingView.receive(transitionedView: self.transitioningView)
                navigationController.showTitle((fromVc as? MADBaseViewController)?.hidesNavigationBarTitle == false)
                navigationController.handleTopPage(for: fromVc)
                navigationController.handleBackButton(for: fromVc, animated: true)
                transitionViewContainer.layer.cornerRadius = isPresenting ? MADPostsCollectionViewController.cellCornerRadius : 0
            }
            
            blurView.effect = nil
            fromTransitioningVc.endTransition(presenting: self.isPresenting, completed: transitionCompleted)
            toTransitioningVc.endTransition(presenting: self.isPresenting, completed: transitionCompleted)
            (transitioningView as? NavigationTransitioningView)?.endTransition(presenting: self.isPresenting, completed: transitionCompleted)
            
            
            blurView.removeFromSuperview()
            transitionViewContainer.removeFromSuperview()
            transitionContext.completeTransition(transitionCompleted)
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    private func getZoomedTransformAndAnchorPoint(for view: UIView, originRect: CGRect, targetRect: CGRect) -> (CGAffineTransform, CGPoint) {
        let centerPointOffset = CGPoint(
            x: targetRect.midX - originRect.midX,
            y: targetRect.midY - originRect.midY)
        let scale: CGFloat = targetRect.width / originRect.width
        let anchorX = originRect.midX / view.bounds.width
        let anchorY = originRect.midY / view.bounds.height
        let anchorPoint = CGPoint(x: anchorX, y: anchorY)
        let transform = CGAffineTransform.identity.translatedBy(x: centerPointOffset.x, y: centerPointOffset.y).scaledBy(x: scale, y: scale)
        return (transform, anchorPoint)
    }
    
    func getTransitionProperties(from originRect: CGRect, to targetRect: CGRect, for transitioningView: UIView) -> TransitionProperties {
        let scaleX = targetRect.width / originRect.width
        let scaleY = targetRect.height / originRect.height
        let scaleAmount = CGPoint(x: scaleX, y: scaleY)
        return TransitionProperties(fromFrame: originRect, toFrame: targetRect, scaleAmount: scaleAmount, transitioningView: transitioningView, isPopping: isPop)
    }
}

