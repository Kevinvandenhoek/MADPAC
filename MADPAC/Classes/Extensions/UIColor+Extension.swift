//
//  UIColor+Extension.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 29/05/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//
import UIKit

extension UIColor {
    
    struct MAD {
        static let black: UIColor = UIColor(hex: "000000")!
        static let white: UIColor = UIColor(hex: "FFFFFF")!
        
        static let loadingGray = UIColor(hex: "CCCCCC")!
        
        static let offWhite: UIColor = UIColor(hex: "F8F8F8")!
        static let offBlack: UIColor = UIColor(hex: "141414")!
        
        static let hotPink: UIColor = UIColor(hex: "DF0061")!
        
        static let darkestGray: UIColor = UIColor(hex: "212121")!
        static let optionsBlack: UIColor = UIColor(hex: "1E1E1E")!
        static let darkGray: UIColor = UIColor(hex: "464646")!
        static let mediumGray: UIColor = UIColor(hex: "787878")!
        static let mediumLightGray: UIColor = UIColor(hex: "888888")!
        static let mediumDarkGray: UIColor = UIColor(hex: "686868")!
        static let lightGray: UIColor = UIColor(hex: "A8A8A8")!
        static let lighterGray: UIColor = UIColor(hex: "C8C8C8")!
        static let lightestGray: UIColor = UIColor(hex: "F0F0F0")!
        
        static let cellBackgroundColor: UIColor = UIColor(hex: "FFFFFF")!
        
        struct HTMLElements {
            static var background: String {
                let color: UIColor = UserPreferences.darkMode ? offBlack : offWhite
                return color.toHex()
            }
            
            static var primaryText: String {
                let color: UIColor = UserPreferences.darkMode ? offWhite : offBlack
                return color.toHex()
            }
            
            static var secondaryText: String {
                let color: UIColor = MAD.UIElements.secondaryText
                return color.toHex()
            }
            
            static var tertiaryText: String {
                let color: UIColor = MAD.UIElements.tertiaryText
                return color.toHex()
            }
            
            static var hotLink: String {
                return hotPink.toHex()
            }
        }
        
        struct UIElements {
            static var primaryTint: UIColor {
                return UserPreferences.darkMode ? offWhite : offBlack
            }
            
            static var logoColor: UIColor {
                return UserPreferences.pinkMadpacLogo ? hotPink : primaryTint
            }
            
            static var secondaryTint: UIColor {
                return UserPreferences.darkMode ? mediumGray : mediumGray
            }
            
            static var cellBackground: UIColor {
                return UserPreferences.darkMode ? darkestGray : white
            }
            
            static var optionsBackground: UIColor {
                return UserPreferences.darkMode ? optionsBlack : lightestGray
            }
            
            static var placeholderBackground: UIColor {
                return UserPreferences.darkMode ? darkestGray : lightGray
            }
            
            static var placeholderTint: UIColor {
                return UserPreferences.darkMode ? darkGray : mediumGray
            }
            
            static var pageBackground: UIColor {
                return UserPreferences.darkMode ? offBlack : offWhite
            }
            
            static var primaryText: UIColor {
                return UserPreferences.darkMode ? offWhite : offBlack
            }
            
            static var secondaryText: UIColor {
                return UserPreferences.darkMode ? lightGray : mediumDarkGray
            }
            
            static var tertiaryText: UIColor {
                return UserPreferences.darkMode ? mediumGray : lightGray
            }
            
            static var subtleTint: UIColor {
                return UserPreferences.darkMode ? darkGray : lighterGray
            }
            
            static var selector: UIColor {
                return UserPreferences.darkMode
                ? UIColor.white.withAlphaComponent(0.1)
                : UIColor.black.withAlphaComponent(0.1)
            }
        }
    }
    
    convenience init?(hex: String?) {
        guard let wrappedHex = hex else { return nil }
        let hex = wrappedHex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    func toHex() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return NSString(format:"#%06x", rgb) as String
    }
}
