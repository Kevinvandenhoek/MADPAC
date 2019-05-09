//
//  TIFDateFormatterFactory.swift
//  Pods
//
//  Created by Antoine van der Lee on 14/01/16.
//
//

import Foundation

public final class TIFDateFormatterFactory {
    
    static let sharedFactory = TIFDateFormatterFactory()
    
    private var cachedDateFormatters = [DateFormatter]()
    private lazy var nlLocale = Locale(identifier: "nl_NL")
    
    public static func dateFormatterForDateStyle(_ dateStyle:DateFormatter.Style? = nil, timeStyle:DateFormatter.Style? = nil, locale:Locale? = nil) -> DateFormatter {
        return sharedFactory.dateFormatterForDateStyle(dateStyle, timeStyle: timeStyle, locale: locale)
    }
    
    func dateFormatterForDateStyle(_ dateStyle:DateFormatter.Style? = nil, timeStyle:DateFormatter.Style? = nil, locale:Locale? = nil) -> DateFormatter {
        for dateFormatter in cachedDateFormatters {
            if let locale = locale, dateFormatter.locale != locale {
                continue
            }
            if let dateStyle = dateStyle, dateFormatter.dateStyle != dateStyle {
                continue
            }
            if let timeStyle = timeStyle, dateFormatter.timeStyle != timeStyle {
                continue
            }
            
            return dateFormatter
            
        }
        
        // Dateformatter not found yet
        // Create it
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        
        if let timeStyle = timeStyle {
            dateFormatter.timeStyle = timeStyle
        }
        if let dateStyle = dateStyle {
            dateFormatter.dateStyle = dateStyle
        }
        
        // Cache the new dateformatter
        cachedDateFormatters.append(dateFormatter)
        
        return dateFormatter
    }
    
    public static func nlDateFormatter(_ timezone:TimeZone? = TimeZone(abbreviation: "UTC")) -> DateFormatter {
        return sharedFactory.nlDateFormatter(timezone)
    }
    
    func nlDateFormatter(_ timezone:TimeZone? = TimeZone(abbreviation: "UTC")) -> DateFormatter {
        
        let nlDateFormatter = cachedDateFormatters.filter { (dateFormatter) -> Bool in
            return dateFormatter.timeZone == timezone && dateFormatter.locale == nlLocale
        }.first
        
        if let nlDateFormatter = nlDateFormatter {
            return nlDateFormatter
        } else {
            // We don't have a dateformatter for this timezone yet
            let dateFormatter = DateFormatter()
            dateFormatter.locale = nlLocale
            dateFormatter.timeZone = timezone
            
            // Cache the new dateformatter
            cachedDateFormatters.append(dateFormatter)
            
            return dateFormatter
        }
    }
}

extension Date {
    public func stringValueForFormat(_ format:String, timezone:TimeZone? = nil) -> String {
        let dateFormatter = TIFDateFormatterFactory.nlDateFormatter(timezone)
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

