//
//  MADTopView.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 14/07/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit

protocol MADTopViewNavigationControllerDelegate: AnyObject {
    func updateTopBarOffset(to offset: CGFloat)
}

class MADTopView: MADView {
    
    var baseHeight: CGFloat { return 50 }
    var minimumHeight: CGFloat { return 0 }
    weak var navigationControllerDelegate: MADTopViewNavigationControllerDelegate?
    
    override func setup() {
        super.setup()
        
        backgroundColor = .clear
    }
    
    func displayOffset(lerpAmount: CGFloat) {
        // Override
    }
}
