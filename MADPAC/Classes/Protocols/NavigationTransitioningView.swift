//
//  NavigationTransitioningView.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 15/07/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit

struct TransitionProperties {
    let fromFrame: CGRect
    let toFrame: CGRect
    let scaleAmount: CGPoint
    let transitioningView: UIView?
    let isPopping: Bool
    
    static var zero: TransitionProperties {
        return TransitionProperties(fromFrame: CGRect.zero, toFrame: CGRect.zero, scaleAmount: CGPoint.zero, transitioningView: nil, isPopping: false)
    }
}

protocol NavigationTransitioningView {
    func getTransitioningView<T: UIView>() -> T?
    func getTargetRect() -> CGRect?
    func receive(transitionedView: UIView)
    func allows(view: UIView) -> Bool
    
    func prepareForTransition(presenting: Bool, isTargetVc: Bool, transitionProperties: TransitionProperties)
    func animateInTransition(presenting: Bool, isTargetVc: Bool)
    func endTransition(presenting: Bool, completed: Bool)
}
