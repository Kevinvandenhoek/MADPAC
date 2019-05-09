//
//  MADTabBarController.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 29/05/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import EasyPeasy

class MADTabBarController: UITabBarController {
    
    static var instance: MADTabBarController?
    
    var animating: Bool = false
    var tabBarIsHidden: Bool = false
    var performedInitialAnimation: Bool = false
    var blurEffect: UIBlurEffect { return UIBlurEffect(style: UserPreferences.darkMode ? .dark : .extraLight) }
    lazy var backgroundView: UIVisualEffectView = {
        let backgroundView = UIVisualEffectView(effect: blurEffect)
        backgroundView.layer.zPosition = -1
        backgroundView.isUserInteractionEnabled = false
        return backgroundView
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(appInit: MADAppInit?) {
        super.init(nibName: nil, bundle: nil)
        setup(with: appInit)
    }
    
    func setup(with appInit: MADAppInit?) {
        
        if let appInit = appInit {
            var vcs: [MADNavigationViewController] = [
                MADNavigationViewController(rootViewController: MADHomeViewController())
            ]
            if appInit.menu?.contains(where: { $0?.label?.lowercased() == "video" }) == true {
                vcs.append(MADNavigationViewController(rootViewController: MADVideoViewController()))
            }
            if appInit.menu?.contains(where: { $0?.label?.lowercased() == "photo" }) == true {
                vcs.append(MADNavigationViewController(rootViewController: MADPhotoViewController()))
            }
            if appInit.menu?.contains(where: { $0?.label?.lowercased() == "interviews" }) == true {
                vcs.append(MADNavigationViewController(rootViewController: MADInterviewsViewController()))
            }
            vcs.append(MADNavigationViewController(rootViewController: MADMoreViewController()))
            viewControllers = vcs
        } else {
            viewControllers = [
                MADNavigationViewController(rootViewController: MADHomeViewController()),
                MADNavigationViewController(rootViewController: MADVideoViewController()),
                MADNavigationViewController(rootViewController: MADPhotoViewController()),
                MADNavigationViewController(rootViewController: MADInterviewsViewController()),
                MADNavigationViewController(rootViewController: MADMoreViewController())
            ]
        }
        
        MADTabBarController.instance = self
        delegate = self
        
        // Stylize the tabbar
        tabBar.backgroundImage = UIImage()
        tabBar.addSubview(backgroundView)
        backgroundView.easy.layout([Left(), Top(), Right(), Bottom(-10)])
        UITabBarItem.appearance().setTitleTextAttributes([
            NSAttributedStringKey.font : UIFont(fontStyle: .regular, size: 10)
            ], for: .normal)
        
        updateColors()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard !performedInitialAnimation else { return }
        tabBar.transform = CGAffineTransform.identity.translatedBy(x: 0, y: 20)
        tabBar.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: { [weak self] in
            guard let `self` = self else { return }
            self.tabBar.transform = CGAffineTransform.identity
            self.tabBar.alpha = 1
        }) { [weak self] (_) in
            self?.performedInitialAnimation = true
        }
    }
}

// Custom delegate for customized transitioning
extension MADTabBarController: UITabBarControllerDelegate {
    
    // Custom tab transition animation
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        guard let fromView = tabBarController.selectedViewController?.view,
            let fromVC = tabBarController.selectedViewController,
            let toView = viewController.view,
            let sView = fromView.superview
            else { // Required objects for custom animation could not be unwrapped
                return true
        }
        
        guard !animating else { return false }
        
        if fromView != toView { // User tapped a different tab
            let toVC = viewController
            toVC.viewWillAppear(false)
            let toIndex = tabBarController.viewControllers!.index(of: viewController)!
            let fromIndex = tabBarController.viewControllers!.index(of: tabBarController.selectedViewController!)!
            let left = (toIndex > fromIndex)
            let offset = min(fromView.frame.width / 3, 150)
            
            toView.frame = CGRect(x: offset * (left ? 1 : -1), y: 0, width: sView.frame.width, height: sView.frame.height)
            toView.alpha = 0
            sView.addSubview(toView)
            fromView.alpha = 1
            animating = true
            UIView.animate(withDuration: UserPreferences.slowAnimations ? 1 : 0.2, delay: 0, options: .curveEaseOut, animations: {
                toView.alpha = 1
                toView.frame = CGRect(x: 0, y: 0, width: sView.frame.width, height: sView.frame.height)
                fromView.frame = CGRect(x: -offset * (left ? 1 : -1), y: 0, width: sView.frame.width, height: sView.frame.height)
                fromView.alpha = 0
            }, completion: { [weak self] (_) in
                fromView.removeFromSuperview()
                fromView.alpha = 1
                ((fromVC as? MADNavigationViewController)?.viewControllers.first as? TabbedPage)?.becameDeselectedTab()
                ((toVC as? MADNavigationViewController)?.viewControllers.first as? TabbedPage)?.becameSelectedTab()
                self?.selectedIndex = toIndex
                self?.animating = false
            })
            return false
        } else {
            return true
        }
    }
}

extension MADTabBarController: ColorUpdatable {
    
    func updateColors() {
        guard let viewControllers = viewControllers else { return }
        for tabbedVC in viewControllers {
            guard selectedViewController !== tabbedVC else { continue }
            updateColors(in: tabbedVC)
        }
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let `self` = self else { return }
            self.backgroundView.effect = self.blurEffect
            self.tabBar.tintColor = UIColor.MAD.UIElements.primaryTint
            self.tabBar.unselectedItemTintColor = UIColor.MAD.UIElements.secondaryTint
            self.view.backgroundColor = UIColor.MAD.UIElements.pageBackground
            self.updateColors(in: self.selectedViewController)
        }
        
    }
    
    private func updateColors(in tabbedVC: UIViewController?) {
        guard let tabbedVC = tabbedVC else { return }
        if let navigationVC = tabbedVC as? UINavigationController {
            if let colorUpdatableNavigationVC = navigationVC as? ColorUpdatable {
                colorUpdatableNavigationVC.updateColors()
            }
            for vC in navigationVC.viewControllers {
                if let colorUpdatableVC = vC as? ColorUpdatable {
                    colorUpdatableVC.updateColors()
                }
                if let presentedUpdatableVC = vC.presentedViewController as? ColorUpdatable {
                    presentedUpdatableVC.updateColors()
                }
            }
        } else if let vC = tabbedVC as? ColorUpdatable {
            vC.updateColors()
        }
    }
}
