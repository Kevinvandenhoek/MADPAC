//
//  MADArticleDetailViewController.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 21/07/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit

class MADArticleDetailViewController: MADDetailViewController {
    
    override var baseHeaderHeight: CGFloat { return UIScreen.main.bounds.width / (4 / 3) }
    
    override func initialize() {
        super.initialize()
        headerView = MADDetailHeaderView()
    }
}
