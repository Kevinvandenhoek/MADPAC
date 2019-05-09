//
//  MADVideoTopView.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 14/07/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import EasyPeasy

protocol MADVideoTopViewDelegate: AnyObject {
    func didTapBottomBar()
}

class MADVideoTopView: MADTopView {
    
    private let bottomView = MADVideoBottomView()
    private let bottomBarHeight: CGFloat = 90
    override var baseHeight: CGFloat { return UIScreen.main.bounds.width * (9 / 16) + bottomBarHeight }
    override var minimumHeight: CGFloat { return UIScreen.main.bounds.width * (9 / 16) + 5 }
    
    var playerView: MADVideoPlayerView = MADVideoPlayerView()
    var currentVideo: MADVideo? { return playerView.currentVideo }
    weak var delegate: MADVideoTopViewDelegate?
    
    override func setup() {
        super.setup()
        
        addSubview(bottomView)
        bottomView.easy.layout([Left(), Right(), Bottom(), Height(bottomBarHeight)])
        
        addSubview(playerView)
        
        bottomView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapBottomBar)))
    }
    
    func open(_ post: MADPost, play: Bool = true) {
        bottomView.update(with: post)
        playerView.update(with: post, play: play)
    }
    
    func updateInTransition(for isPresenting: Bool) {
        bottomView.updateArrowInNavigationAnimation(for: isPresenting)
        navigationControllerDelegate?.updateTopBarOffset(to: 0)
    }
    
    func updateFrames() {
        playerView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.width * (9 / 16))
    }
    
    @objc func didTapBottomBar() {
        delegate?.didTapBottomBar()
    }
    
    override var frame: CGRect {
        didSet {
            updateFrames()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateFrames()
    }
}

extension MADVideoTopView: ColorUpdatable {
    
    func updateColors() {
        bottomView.updateColors()
        playerView.updateColors()
    }
}
