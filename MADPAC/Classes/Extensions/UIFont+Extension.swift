//
//  UIFont+Extension.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 30/05/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit

public enum FontStyle: String {
    case bold       = "Lato-Bold"
    case regular    = "Lato-Regular"
    case light      = "Lato-Light"
}

public extension UIFont {
    
    func getWidthFor(text: String, height: CGFloat = .greatestFiniteMagnitude) -> CGFloat {
        let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSAttributedStringKey.font: self]
        let estimatedRect = NSString(string: text).boundingRect(with: size, options: options, attributes: attributes, context: nil)
        return estimatedRect.width
    }
    
    func getHeightFor(text: String, width: CGFloat = CGFloat.greatestFiniteMagnitude) -> CGFloat {
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSAttributedStringKey.font: self]
        let estimatedRect = NSString(string: text).boundingRect(with: size, options: options, attributes: attributes, context: nil)
        return estimatedRect.height
    }
    
    public struct MAD {
        static func avenirLight(size: CGFloat) -> UIFont {
            return UIFont(name: "Avenir-Light", size: size)!
        }
        
        static func avenirMedium(size: CGFloat) -> UIFont {
            return UIFont(name: "Avenir-Medium", size: size)!
        }
    }
    
    public convenience init(fontStyle: FontStyle, size: CGFloat) {
        self.init(name: fontStyle.rawValue, size: size)!
    }
}
