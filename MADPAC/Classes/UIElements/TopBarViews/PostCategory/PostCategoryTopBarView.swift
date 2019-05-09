//
//  PostCategoryTopBarView.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 14/07/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import EasyPeasy

protocol PostCategoryTopBarViewDelegate: AnyObject {
    func didSelect(category: String?)
}

class PostCategoryTopBarView: MADTopView {
    
    override var baseHeight: CGFloat { return 40 }
    
    let segmentedControl = MADSegmentedControl()
    weak var delegate: PostCategoryTopBarViewDelegate?
    
    var categories: [String] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    init(with delegate: PostCategoryTopBarViewDelegate) {
        self.delegate = delegate
        super.init(frame: CGRect.zero)
    }
    
    override func setup() {
        super.setup()
        
        clipsToBounds = false
        addSubview(segmentedControl)
        segmentedControl.delegate = self
        segmentedControl.easy.layout([Left(), Right(), Height(30), Bottom(10)])
        segmentedControl.bottomSeparatorColor = .clear
        segmentedControl.backgroundColor = .clear
        segmentedControl.sideInset = 15
        segmentedControl.cellSpacing = 5
        segmentedControl.separatorThickness = 30
        segmentedControl.cellLabelMargin = 15
        
        updateColors()
    }
    
    func setup(with categories: [String]?) {
        self.categories = categories ?? []
        if !self.categories.contains(where: { $0.uppercased() == "TRENDING" }) {
            self.categories.insert("TRENDING", at: 0)
        }
        segmentedControl.setup(with: self.categories, startIndex: 0)
    }
    
    override func displayOffset(lerpAmount: CGFloat) {
        alpha = 1 - min(lerpAmount * 2, 1)
        isUserInteractionEnabled = alpha > 0.5
    }
}

extension PostCategoryTopBarView: MADSegmentedControlDelegate {
    func didSelect(index: Int) {
        delegate?.didSelect(category: categories[safe: index])
    }
}

extension PostCategoryTopBarView: ColorUpdatable {
    func updateColors() {
        segmentedControl.selectorColor = UIColor.MAD.UIElements.selector
        segmentedControl.setTintColor(UIColor.MAD.UIElements.tertiaryText, state: .normal)
        segmentedControl.setTintColor(UIColor.MAD.UIElements.primaryText, state: .selected)
        segmentedControl.updateColors()
    }
}
