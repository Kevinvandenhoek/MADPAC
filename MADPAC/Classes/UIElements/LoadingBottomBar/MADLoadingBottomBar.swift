//
//  MADLoadingBottomBar.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 22/07/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import EasyPeasy

protocol MADLoadingBottomBarDelegate: AnyObject {
    func didRequestRefresh(sender: MADLoadingBottomBar)
}

class MADLoadingBottomBar: MADView {
    
    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    let pullToReloadImageView = UIImageView(image: #imageLiteral(resourceName: "icon_pulltoreload").withRenderingMode(.alwaysTemplate))
    var isLoading: Bool = false
    private(set) var isOnCooldown: Bool = false
    weak var delegate: MADLoadingBottomBarDelegate?
    
    private var yOffset: CGFloat = 0
    
    override func setup() {
        super.setup()
        
        clipsToBounds = false
        addSubview(activityIndicatorView)
        activityIndicatorView.easy.layout([Edges()])
        
        pullToReloadImageView.contentMode = .center
        addSubview(pullToReloadImageView)
        pullToReloadImageView.easy.layout([Edges()])
        pullToReloadImageView.alpha = 0
        
        updateColors()
    }
    
    func startCooldown() {
        isOnCooldown = true
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) { [weak self] in
            guard let `self` = self else { return }
            self.isOnCooldown = false
        }
    }
    
    func lerpVisibility(_ lerpAmount: CGFloat, distance: CGFloat) {
        let lerp = max(min(lerpAmount, 1), 0)
        var extraInset: CGFloat = 0
        if #available(iOS 11.0, *) {
            extraInset = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        }
        let offset = (((1 - lerp) * distance) + (lerp * 0)) - extraInset
        self.activityIndicatorView.alpha = lerp
        self.activityIndicatorView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: offset)
        self.pullToReloadImageView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: offset)
        self.yOffset = offset
    }
    
    func lerpPullToReload(_ lerpValue: CGFloat) {
        guard !isOnCooldown, !isLoading else { return }
        if lerpValue < 1 {
            let lerp = max(min(lerpValue, 1), 0)
            let lerpScale = (lerp * 0.3) + 0.7
            self.pullToReloadImageView.alpha = lerp
            self.pullToReloadImageView.transform = CGAffineTransform.identity.scaledBy(x: lerpScale, y: lerpScale).translatedBy(x: 0, y: lerp * yOffset)
        } else {
            showLoading(true)
            self.pullToReloadImageView.alpha = 1
            UIView.animate(withDuration: 0.2) { [weak self] in
                guard let `self` = self else { return }
                self.pullToReloadImageView.alpha = 0
                self.pullToReloadImageView.transform = CGAffineTransform.identity.scaledBy(x: 0.7, y: 0.7).translatedBy(x: 0, y: self.yOffset)
            }
            delegate?.didRequestRefresh(sender: self)
            HapticFeedbackHelper.shared.generateImpact(.medium)
        }
    }
    
    func showLoading(_ loading: Bool) {
        guard loading != isLoading else { return }
        isLoading = loading
        startCooldown()
        if loading {
            activityIndicatorView.startAnimating()
            pullToReloadImageView.alpha = 0
        } else {
            activityIndicatorView.stopAnimating()
        }
    }
    
    func setVisibility(_ visible: Bool, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.pullToReloadImageView.alpha = visible ? 1 : 0
                self?.activityIndicatorView.alpha = visible ? 1 : 0
            }
        } else {
            self.pullToReloadImageView.alpha = visible ? 1 : 0
            self.activityIndicatorView.alpha = visible ? 1 : 0
        }
    }
}

extension MADLoadingBottomBar: ColorUpdatable {
    
    func updateColors() {
        activityIndicatorView.color = UIColor.MAD.UIElements.primaryText
        pullToReloadImageView.tintColor = UIColor.MAD.UIElements.secondaryText
    }
}
