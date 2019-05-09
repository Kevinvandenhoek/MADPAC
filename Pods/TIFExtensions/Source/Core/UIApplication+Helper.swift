//
//  UIApplication+Helper.swift
//  Buienradar
//
//  Created by Antoine van der Lee on 01/02/16.
//  Copyright © 2016 Triple. All rights reserved.
//

import Foundation
import UIKit

public extension UIApplication {
    var appVersionNumber: String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    var buildVersionNumber: String? {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    }
    
    var versionBuildNumber:String? {
        return String(format: "%@ (%@)", appVersionNumber ?? "", buildVersionNumber ?? "")
    }
    
    // Used by Watch apps that do not have a UIApplication class
    @available(*, deprecated, message: "Use shared")
    class var sharedApplicationValue:UIApplication? {
        return sharedValue
    }
    
    @available(*, deprecated, message: "Use shared")
    class var sharedValue: UIApplication? {
        let selector = NSSelectorFromString("sharedApplication")
        guard responds(to: selector) else { return nil }
        return perform(selector).takeUnretainedValue() as? UIApplication
    }
}

public extension UIApplication {
    
    #if !os(tvOS)
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController {
            let moreNavigationController = tab.moreNavigationController
            
            if let top = moreNavigationController.topViewController, top.view.window != nil {
                return topViewController(base: top)
            } else if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        
        return base
    }
    
    class func openSettings() {
        guard let url = URL(string: UIApplicationOpenSettingsURLString), UIApplication.shared.canOpenURL(url) == true else { return }
        if UIApplication.shared.responds(to: #selector(UIApplication.openURL(_:))) == true {
            UIApplication.shared.performSelector(inBackground: #selector(UIApplication.openURL(_:)), with: url)
        }
    }
    
    /// Width based on current orientation
    var screenWidthBasedOnOrientation: CGFloat {
        if UIInterfaceOrientationIsPortrait(screenOrientation) {
            return min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        } else {
            return max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        }
    }
    
    /// Width based on current orientation
    var screenHeightBasedOnOrientation: CGFloat {
        if UIInterfaceOrientationIsPortrait(screenOrientation) {
            return UIScreen.main.bounds.size.height
        } else {
            return UIScreen.main.bounds.size.width
        }
    }
    
    /// Get current screen orientation, shortcut
    var screenOrientation: UIInterfaceOrientation {
        return UIApplication.shared.statusBarOrientation
    }
    #endif
}
