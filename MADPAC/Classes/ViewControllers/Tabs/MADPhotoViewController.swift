//
//  MADPhotoViewController.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 29/05/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit

class MADPhotoViewController: MADPostsCollectionViewController {
    
    override var category: String? { return "photo" }
    
    override func cellTypeFor(indexPath: IndexPath) -> MADPostCollectionViewCell.Type {
        return MADPhotoCollectionViewCell.self
    }
}

extension MADPhotoViewController: TabbedPage {
    
    var tabImage: UIImage { return #imageLiteral(resourceName: "tabbar_photo") }
    var pageTitle: String { return "PHOTO" }
    var tabTitle: String? { return pageTitle }
}
