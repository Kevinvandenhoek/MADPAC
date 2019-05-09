//
//  UIViewController+Helper.swift
//
//  Created by AvdLee on 08/12/14.
//  Copyright (c) 2014 Triple IT. All rights reserved.
//

import Foundation

public extension UIViewController {
    
    /// Adds given viewcontroller as a child to given view
    func add(childController viewController:UIViewController, toView:UIView) {
        self.addChildViewController(viewController)
        toView.addSubview(viewController.view)
        viewController.didMove(toParentViewController: self)
    }
    
    /// Adds given viewcontroller as a child to given view below another view
    func insert(childController viewController:UIViewController, toView:UIView, belowView:UIView) {
        self.addChildViewController(viewController)
        toView.insertSubview(viewController.view, belowSubview:belowView)
        viewController.didMove(toParentViewController: self)
    }
    
    /// Removed given viewcontroller as child
    func remove(childController viewController:UIViewController) {
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }
    
    func addPushBackAnimation(){
        let transition = CATransition()
        transition.duration = 0.35
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionReveal
        transition.subtype = kCATransitionFromLeft
        
        let containerView = self.view.window
        containerView?.layer.add(transition, forKey: nil)
    }
    
    /// This will be true if the viewController is presented modally
    var isModalPresented: Bool {
        return self.presentingViewController?.presentedViewController == self
            || (self.navigationController != nil && self.navigationController?.presentingViewController?.presentedViewController == self.navigationController)
            || self.tabBarController?.presentingViewController is UITabBarController
    }
    
    /**
     Instantiate viewController from given storyBoard with given type
     
     - parameter storyboard: storyboard to use when instatiating viewController, defaults to Main storyboard
     
     - returns: optional viewController of given type
     */
    class func instantiateFromStoryboard<T> (_ storyboard: UIStoryboard = UIStoryboard.mainStoryboard()) -> T? {
        if let name = NSStringFromClass(self).components(separatedBy: ".").last {
            if let vc = storyboard.instantiateViewController(withIdentifier: name) as? T {
                return vc
            }
        }
        return nil
    }
}
