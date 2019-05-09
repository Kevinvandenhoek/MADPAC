//
//  UIStoryboard+Helper.swift
//
//  Created by AvdLee on 10/12/14.
//  Copyright (c) 2014 Triple IT. All rights reserved.
//

import UIKit

public extension UIStoryboard {
    
    /// Instantiates view controller from storyboard
    func instantiateVC<T: UIViewController>() -> T {
        // get a class name and demangle for classes in Swift
        if let name = NSStringFromClass(T.self).components(separatedBy: ".").last, let vc = instantiateViewController(withIdentifier: name) as? T {
            return vc
        }
        return T(nibName: nil, bundle: nil)
    }
    
    /// Returns the main storyboard defined in the info.plist file
    class func mainStoryboard() -> UIStoryboard {
        let storyboardName = Bundle.main.infoDictionary?["UIMainStoryboardFile"] as! String
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        return storyboard
    }
}
