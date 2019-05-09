//
//  MADPlayButton.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 30/05/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import EasyPeasy

class MADPlayButton: MADButton {
    
    let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    let blurView = MADBlurView()
    let maskImageView = MADImageView(image: #imageLiteral(resourceName: "icon_play_mask"))
    let outlineImageView = MADImageView(image: #imageLiteral(resourceName: "icon_play_outline"))
    private(set) var fixedBlur = false
    
    override func setup() {
        super.setup()
        
        clipsToBounds = false
        let playSize: CGFloat = 73.5
        
        addSubview(blurView)
        blurView.layer.zPosition = -1
        blurView.easy.layout([Center(), Size(playSize)])
        blurView.isUserInteractionEnabled = false
        blurView.setBlur(amount: 0.3)
        
        addSubview(maskImageView)
        maskImageView.contentMode = .scaleToFill
        maskImageView.easy.layout([Center(), Size(playSize)])
        blurView.mask = maskImageView
        
        addSubview(outlineImageView)
        outlineImageView.contentMode = .scaleToFill
        outlineImageView.easy.layout([Center(), Size(playSize)])
        
        addSubview(activityView)
        activityView.easy.layout([Edges()])
        activityView.isUserInteractionEnabled = false
        
        title = nil
        image = UIImage(named: "icon_play")!.withRenderingMode(.alwaysTemplate)
        self.imageView?.contentMode = .center
        self.imageView?.clipsToBounds = false
        tintColor = .white
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let width: CGFloat = 20.35
        let height: CGFloat = 24.5
        return CGRect(x: (bounds.width - width) / 2 + 3, y: (bounds.height - height) / 2, width: width, height: height)
    }
    
    func show(animated: Bool) {
        UIView.animate(withDuration: animated ? 0.2 : 0, animations: { [weak self] in
            guard let `self` = self else { return }
            self.alpha = 1
        })
    }
    
    func hide(animated: Bool, completion: ((Bool) -> Void)?) {
        UIView.animate(withDuration: animated ? 0.2 : 0, animations: { [weak self] in
            guard let `self` = self else { return }
            self.alpha = 0
        }) { (completed) in
            completion?(completed)
        }
    }
    
    func fixBlur() {
        guard !fixedBlur else { return }
        fixedBlur = true
        blurView.setBlur(amount: 0.3)
    }
    
    func reset() {
        activityView.stopAnimating()
        self.tintColor = .white
        show(animated: false)
    }
    
    func display(state: MADVideoView.PlaybackStatus) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            if state == .loading {
                self.enableIconShadow(false)
                self.blurView.alpha = 1
                self.outlineImageView.alpha = 1
                self.image = nil
                self.activityView.startAnimating()
            } else if state == .playing {
                self.enableIconShadow(true)
                self.blurView.alpha = 0
                self.outlineImageView.alpha = 0
                self.image = UIImage(named: "icon_pause")
                self.activityView.stopAnimating()
            } else {
                self.enableIconShadow(false)
                self.blurView.alpha = 1
                self.outlineImageView.alpha = 1
                self.image = UIImage(named: "icon_play")
                self.activityView.stopAnimating()
            }
        }
    }
    
    func enableIconShadow(_ enable: Bool) {
        self.imageView?.layer.shadowRadius = 5
        self.imageView?.layer.shadowOpacity = enable ? 0.4 : 0
        self.imageView?.layer.shadowColor = UIColor.black.cgColor
        self.imageView?.layer.shadowOffset = CGSize(width: 0, height: 2)
    }
    
    override var isHighlighted: Bool {
        didSet {
            displayHighlighted(isHighlighted)
        }
    }
    
    func displayHighlighted(_ highlighted: Bool) {
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: [.curveEaseInOut, .allowUserInteraction], animations: { [weak self] in
            guard let `self` = self else { return }
            let scale: CGFloat = highlighted ? 0.9 : 1
            self.maskImageView.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale)
            self.outlineImageView.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale)
        })
    }
}
