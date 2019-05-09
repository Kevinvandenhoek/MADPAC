//
//  MADVideoHeaderView.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 15/07/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import EasyPeasy

protocol MADDetailVideoHeaderViewDelegate: AnyObject {
    func didReceiveNewTransitioningView()
}

class MADDetailVideoHeaderView: MADDetailHeaderView {
    var transformingVideoView: TransformingVideoPlayerView?
    weak var delegate: MADDetailVideoHeaderViewDelegate?
    
    override func setup() {
        super.setup()
        
        clipsToBounds = false
    }
    
    override func setupTransitioningView() {
        return
//        guard self.transformingVideoView == nil else { return }
//        self.transformingVideoView = TransformingVideoPlayerView()
//        addSubview(transformingVideoView!)
//        transformingVideoView?.alpha = 0 // TODO: This is a hack
//        transformingVideoView?.easy.layout([Edges()])
    }
    
    override func getTransitioningView<T>() -> T? where T : UIView {
        return transformingVideoView as? T
    }
    
    override func receive(transitionedView: UIView) {
        guard let receivedTransformingVideoView = transitionedView as? TransformingVideoPlayerView else {
            fatalError()
        }
        self.transformingVideoView?.removeFromSuperview()
        self.transformingVideoView = receivedTransformingVideoView
        addSubview(receivedTransformingVideoView)
        self.transformingVideoView?.easy.layout([Edges()])
    }
    
    override func allows(view: UIView) -> Bool {
        return type(of: view.self) == TransformingVideoPlayerView.self
    }
    
    override func endTransition(presenting: Bool, completed: Bool) {
        super.endTransition(presenting: presenting, completed: completed)
        if completed {
            delegate?.didReceiveNewTransitioningView()
            if !presenting {
                self.transformingVideoView = nil
            }
        }
    }
}
