//
//  MADImageView.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 30/05/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import Nuke
import EasyPeasy

protocol MADImageViewDelegate: AnyObject {
    func placeholder(isDisplaying: Bool)
}

class MADImageView: UIImageView {
    
    private let placeholderView = UIImageView(image: #imageLiteral(resourceName: "placeholderA").withRenderingMode(.alwaysTemplate))
    
    weak var delegate: MADImageViewDelegate?
    
    override var image: UIImage? {
        didSet {
            displayPlaceholder(image == nil)
        }
    }
    
    func displayPlaceholder(_ display: Bool) {
        placeholderView.alpha = display ? 1 : 0
        delegate?.placeholder(isDisplaying: display)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        setup()
    }
    
    func setup() {
        clipsToBounds = true
        contentMode = .scaleAspectFill
        
        addSubview(placeholderView)
        placeholderView.easy.layout([Edges()])
        placeholderView.contentMode = .center
        displayPlaceholder(image == nil)
        updateColors()
    }
}

extension MADImageView: ColorUpdatable {
    func updateColors() {
        placeholderView.tintColor = UIColor.MAD.UIElements.placeholderTint
        placeholderView.backgroundColor = UIColor.MAD.UIElements.placeholderBackground
    }
}
