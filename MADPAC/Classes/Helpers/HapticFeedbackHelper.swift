//
//  TapticsHelper.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 22/07/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit

class HapticFeedbackHelper {
    
    static var shared: HapticFeedbackHelper = { return HapticFeedbackHelper() }()
    
    private let feedbackGenerator = UINotificationFeedbackGenerator()
    
    func generateImpact(_ style: UIImpactFeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
    
    func generateFeedback(_ type: UINotificationFeedbackType) {
        feedbackGenerator.notificationOccurred(type)
    }
}
