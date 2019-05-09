//
//  TIFOrientationHelper.swift
//  Buienradar
//
//  Created by Antoine van der Lee on 30/03/16.
//  Copyright © 2016 Triple. All rights reserved.
//

import Foundation
import UIKit

#if !os(tvOS)
    public enum TIFOrientation : String {
        case portrait = "portrait"
        case landscape = "landscape"
        
        public var isLandscape:Bool {
            return self == .landscape
        }
        public var isPortrait:Bool {
            return self == .portrait
        }
        
        public var width:CGFloat {
            switch self {
            case .portrait:
                return min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
            case .landscape:
                return max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
            }
        }
    }
    
    public final class TIFOrientationHelper {
        public static var currentOrientation:TIFOrientation {
            if UIApplication.shared.statusBarOrientation.isLandscape {
                return .landscape
            }
            
            return .portrait
        }
    }
#endif
