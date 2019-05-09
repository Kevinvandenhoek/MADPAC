//
//  UserPreferences.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 13/07/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import Foundation

class UserPreferences {
    
    static var videoQualityPreference: DataUsagePreference? = UserDefaults.standard.videoQualityPreference {
        didSet {
            guard videoQualityPreference != UserDefaults.standard.videoQualityPreference else { return }
            UserDefaults.standard.videoQualityPreference = videoQualityPreference
        }
    }
    
    static var highVideoQuality: Bool { // TODO: Check for wifi
        return UserPreferences.videoQualityPreference == .high || UserPreferences.videoQualityPreference == .wifi
    }
    
    static var darkMode: Bool = UserDefaults.standard.darkMode {
        didSet {
            guard darkMode != UserDefaults.standard.darkMode else { return }
            print("Did set to darkmode: \(darkMode)")
            UserDefaults.standard.darkMode = darkMode
            MADTabBarController.instance?.updateColors()
        }
    }
    
    static var pinkMadpacLogo: Bool = UserDefaults.standard.pinkMadpacLogo {
        didSet {
            guard pinkMadpacLogo != UserDefaults.standard.pinkMadpacLogo else { return }
            UserDefaults.standard.pinkMadpacLogo = pinkMadpacLogo
        }
    }
    
    static var autoPlayPreference: DataUsagePreference? = UserDefaults.standard.autoPlayPreference {
        didSet {
            guard autoPlayPreference != UserDefaults.standard.autoPlayPreference else { return }
            UserDefaults.standard.autoPlayPreference = autoPlayPreference
        }
    }
    
    static var autoPlay: Bool { // TODO: Check for wifi
        return UserPreferences.autoPlayPreference == .high || UserPreferences.autoPlayPreference == .wifi
    }
    
    static var slowAnimations: Bool = UserDefaults.standard.slowAnimations {
        didSet {
            guard slowAnimations != UserDefaults.standard.slowAnimations else { return }
            UserDefaults.standard.slowAnimations = slowAnimations
        }
    }
    
    static var autoHideTabBar: Bool = true //{
//        didSet {
//            guard autoHideTabBar != UserDefaults.standard.autoHideTabBar else { return }
//            UserDefaults.standard.autoHideTabBar = autoHideTabBar
//        }
//    }
    
    static var betaFunctionality: Bool = UserDefaults.standard.betaFunctionality {
        didSet {
            guard betaFunctionality != UserDefaults.standard.betaFunctionality else { return }
            UserDefaults.standard.betaFunctionality = betaFunctionality
        }
    }
    
    static var userDidSeeThemePopover: Bool = UserDefaults.standard.userDidSeeThemePopover {
        didSet {
            guard userDidSeeThemePopover != UserDefaults.standard.userDidSeeThemePopover else { return }
            UserDefaults.standard.userDidSeeThemePopover = userDidSeeThemePopover
        }
    }
    
    static var forceThemePopover: Bool = UserDefaults.standard.forceThemePopover {
        didSet {
            guard forceThemePopover != UserDefaults.standard.forceThemePopover else { return }
            UserDefaults.standard.forceThemePopover = forceThemePopover
        }
    }
    
    struct session {
        static var muteVideo: Bool = true
    }
}
