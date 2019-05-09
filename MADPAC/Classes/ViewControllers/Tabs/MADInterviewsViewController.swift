//
//  MADInterviewsViewController.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 29/05/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit

class MADInterviewsViewController: MADPostsCollectionViewController {
    
    override var category: String? { return "interviews" }
    
    override var cellPadding: CGFloat { return 7.5 }
    override var cellSpacing: CGFloat { return 7.5 }
    override var cellsPerRow: CGFloat { return 2 }
    
    override func cellTypeFor(indexPath: IndexPath) -> MADPostCollectionViewCell.Type {
        return MADInterviewCollectionViewCell.self
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = super.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
        let height = size.width * (4 / 3)
        return CGSize(width: size.width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let items = super.collectionView(collectionView, numberOfItemsInSection: section)
        let isEven = items % 2 == 0
        if isEven {
            return items
        } else {
            return items - 1
        }
    }
    
    override func setup() {
        super.setup()
        
        collectionViewUpdater?.isInterviews = true // Temporary bugfix
    }
}

extension MADInterviewsViewController: TabbedPage {
    
    var tabImage: UIImage { return #imageLiteral(resourceName: "tabbar_interviews") }
    var pageTitle: String { return "INTERVIEWS" }
    var tabTitle: String? { return pageTitle }
}
