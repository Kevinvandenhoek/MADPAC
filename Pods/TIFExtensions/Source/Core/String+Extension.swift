//
//  String+Extension.swift
//
//  Created by Tim Bakker on 06-07-15.
//  Copyright (c) 2015 Triple IT. All rights reserved.
//

import Foundation

public extension String {
    func localized() -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    /// Returns a NSURL from the string. If the string isn't a valid URL, it will return nil
    var urlValue:URL? {
        return URL(string: self)
    }
    
    /// Returns the characters count from string
    @available(*, deprecated, message: "Use .count instead of .length")
    var length: Int { return self.count }
    
    /// Check if string has any content (white spaces and new line characters are trimmed)
    func hasContent() -> Bool {
        let trimmedString = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if trimmedString == "" {
            return false
        }
        
        return true
    }
    
    /// Returns the string without white spaces and new line characters
    var trimmedValue:String? {
        get {
            return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    
    var languageDisplayNameValue:String? {
        get {
            let nlLocale:Locale = Locale(identifier: "nl_NL")
            let displayName:String? = nlLocale.languageCode
            if displayName != nil {
                return displayName
            } else {
                return self
            }
        }
    }
    
    /// Returns the string with the first character uppercased
    func ucfirst() -> String {
        return (self as NSString).replacingCharacters(in: NSMakeRange(0, 1), with: (self as NSString).substring(to: 1).uppercased())
    }
    
    /// Check if string is a valid email
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: self)
        return result
    }
    
    var durationValue:TimeInterval {
        var h, m, s, millis:NSString?
        
        let separators = CharacterSet(charactersIn: ":,.;")
        let scanner = Scanner(string: self)
        scanner.scanUpToCharacters(from: separators, into: &h)
        scanner.scanUpToCharacters(from: CharacterSet.decimalDigits, into: nil)
        scanner.scanUpToCharacters(from: separators, into: &m)
        scanner.scanUpToCharacters(from: CharacterSet.decimalDigits, into: nil)
        scanner.scanUpToCharacters(from: separators, into: &s)
        scanner.scanUpToCharacters(from: CharacterSet.decimalDigits, into: nil)
        scanner.scanUpToCharacters(from: separators, into: &millis)
        
        let hV = h?.integerValue ?? 0
        let mV = m?.integerValue ?? 0
        let sV = s?.integerValue ?? 0
        let milliV = millis?.integerValue ?? 0
        
        let hours = hV * 60 * 60
        let minutes = mV * 60
        let seconds = sV + (milliV/1000)
        
        return TimeInterval(hours + minutes + seconds)
    }
    
    /// Check if string contains given character set
    func containsCharacterSet(_ characterSet: CharacterSet) -> Bool {
        return (rangeOfCharacter(from: characterSet, options: .caseInsensitive, range: nil) != nil)
    }
    
    /// Check if string is alpha numberic
    func isAlphaNumberic() -> Bool {
        var regex: NSRegularExpression?
        do {
            try regex = NSRegularExpression(pattern: ".*[^A-Za-z0-9].*", options: [])
        } catch {
            return false
        }
        
        if let regex = regex, regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil {
            return false
        }
        return true
    }
    
    /// Calculate the bounding rect based on the given font
    func boundingRectWith(font:UIFont) -> CGRect {
        let maximumLabelSize = CGSize(width: UIScreen.main.bounds.size.width, height: CGFloat.greatestFiniteMagnitude);
        let attributes = [NSAttributedStringKey.font: font]
        let rect = self.boundingRect(with: maximumLabelSize, options:.usesLineFragmentOrigin, attributes: attributes, context:nil)
        return rect
    }
    
    /// Use this method to delete a specific tag from the string
    func deleteHTML(tag:String) -> String {
        return self.replacingOccurrences(of:"(?i)</?\(tag)\\b[^<]*>", with: "", options: .regularExpression, range: nil)
    }
    
    /// Use this method to delete specific tags from the string
    func deleteHTML(tags:[String]) -> String {
        var mutableString = self
        for tag in tags {
            mutableString = mutableString.deleteHTML(tag: tag)
        }
        return mutableString
    }
}
