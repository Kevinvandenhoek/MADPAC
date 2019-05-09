//
//  MADLoadingView.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 30/05/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit

class MADLoadingView: MADView {
    override func setup() {
        backgroundColor = UIColor.MAD.loadingGray
        layer.cornerRadius = MADPostsCollectionViewController.cellCornerRadius
    }
}
