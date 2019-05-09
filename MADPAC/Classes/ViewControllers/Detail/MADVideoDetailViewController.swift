//
//  MADVideoDetailViewController.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 15/07/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import EasyPeasy
import AVFoundation

class MADVideoDetailViewController: MADDetailViewController {
    
    private var preferredExtraTopOffset: CGFloat = 0
    override var extraTopOffset: CGFloat { return preferredExtraTopOffset }
    override var minimumHeaderHeight: CGFloat { return UIScreen.main.bounds.width / (16 / 9) }
    
    override func initialize() {
        super.initialize()
        headerView = MADDetailVideoHeaderView()
        (headerView as? MADDetailVideoHeaderView)?.delegate = self
    }
}

extension MADVideoDetailViewController: MADDetailVideoHeaderViewDelegate {
    func didReceiveNewTransitioningView() {
        updateWebviewScrollInsets()
    }
}
