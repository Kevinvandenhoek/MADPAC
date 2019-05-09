//
//  UserDefaults+Extension.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 15/07/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import Foundation

public enum DataUsagePreference: String, Codable {
    case high = "Aan"
    case wifi = "Wifi only"
    case low = "Uit"
}

extension UserDefaults {
    
    public enum Keys: String {
        case videoQualityPreference
        case darkMode
        case autoPlayPreference
        case categories
        case slowAnimations
        case autoHideTabBar
        case betaFunctionality
        case userDidSeeThemePopover
        case forceThemePopover
        case pinkMadpacLogo
        case searchHistory
    }
    
    public var darkMode: Bool {
        get {
            return bool(forKey: Keys.darkMode.rawValue)
        }
        set(value) {
            set(value, forKey: Keys.darkMode.rawValue)
        }
    }
    
    public var pinkMadpacLogo: Bool {
        get {
            return bool(forKey: Keys.pinkMadpacLogo.rawValue)
        }
        set(value) {
            set(value, forKey: Keys.pinkMadpacLogo.rawValue)
        }
    }
    
    public var slowAnimations: Bool {
        get {
            return bool(forKey: Keys.slowAnimations.rawValue)
        }
        set(value) {
            set(value, forKey: Keys.slowAnimations.rawValue)
        }
    }
    
    public var autoHideTabBar: Bool {
        get {
            return bool(forKey: Keys.autoHideTabBar.rawValue)
        }
        set(value) {
            set(value, forKey: Keys.autoHideTabBar.rawValue)
        }
    }
    
    public var betaFunctionality: Bool {
        get {
            return bool(forKey: Keys.betaFunctionality.rawValue)
        }
        set(value) {
            set(value, forKey: Keys.betaFunctionality.rawValue)
        }
    }
    
    public var userDidSeeThemePopover: Bool {
        get {
            return bool(forKey: Keys.userDidSeeThemePopover.rawValue)
        }
        set(value) {
            set(value, forKey: Keys.userDidSeeThemePopover.rawValue)
        }
    }
    
    public var forceThemePopover: Bool {
        get {
            return bool(forKey: Keys.forceThemePopover.rawValue)
        }
        set(value) {
            set(value, forKey: Keys.forceThemePopover.rawValue)
        }
    }
    
    public var videoQualityPreference: DataUsagePreference? {
        get {
            guard let storedString = string(forKey: Keys.videoQualityPreference.rawValue) else { return nil }
            return DataUsagePreference.init(rawValue: storedString)
        }
        set {
            guard newValue != nil else {
                set(nil, forKey: Keys.videoQualityPreference.rawValue)
                return
            }
            set(newValue?.rawValue, forKey: Keys.videoQualityPreference.rawValue)
        }
    }
    
    public var autoPlayPreference: DataUsagePreference? {
        get {
            guard let storedString = string(forKey: Keys.autoPlayPreference.rawValue) else { return nil }
            return DataUsagePreference.init(rawValue: storedString)
        }
        set {
            guard newValue != nil else {
                set(nil, forKey: Keys.autoPlayPreference.rawValue)
                return
            }
            set(newValue?.rawValue, forKey: Keys.autoPlayPreference.rawValue)
        }
    }
    
    public var categories: [String]? {
        get {
            guard let data = object(forKey: Keys.categories.rawValue) as? Data else {
                return nil
            }
            
            let decoder = PropertyListDecoder()
            return try? decoder.decode([String].self, from: data)
        }
        set {
            guard newValue != nil else {
                set(nil, forKey: Keys.categories.rawValue)
                return
            }
            let encoder = PropertyListEncoder()
            guard let categories = newValue, let data = try? encoder.encode(categories) else {
                return
            }
            set(data, forKey: Keys.categories.rawValue)
        }
    }
    
    public var searchHistory: [String] {
        get {
            guard let data = object(forKey: Keys.searchHistory.rawValue) as? Data else {
                return []
            }
            
            let decoder = PropertyListDecoder()
            if let result = try? decoder.decode([String].self, from: data) {
                return result
            } else {
                return []
            }
        }
        set {
            let encoder = PropertyListEncoder()
            guard let data = try? encoder.encode(newValue.safeSuffix(6)) else {
                return
            }
            set(data, forKey: Keys.searchHistory.rawValue)
        }
    }
}
