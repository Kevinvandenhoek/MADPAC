//
//  MADPopoverWindow.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 05/08/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import EasyPeasy

class MADPopoverViewController: UIViewController, ColorUpdatable {
    
    let containerView = MADView()
    let backgroundTapGestureView = UIView()
    let visualEffectView = UIVisualEffectView(effect: nil)
    var blurEffect: UIVisualEffect { return UIBlurEffect(style: UserPreferences.darkMode ? .dark : .extraLight) }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    func setup() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        view.addSubview(backgroundTapGestureView)
        backgroundTapGestureView.easy.layout([Edges()])
        backgroundTapGestureView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapBackground)))
        
        view.addSubview(containerView)
        containerView.layer.cornerRadius = 23
        containerView.easy.layout([Center(), Width(300), Height(>=20)])
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 30
        view.layer.shadowOffset = CGSize(width: 0, height: 5)
        
        containerView.addSubview(visualEffectView)
        visualEffectView.easy.layout([Edges()])
        
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
        
        updateColors()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        containerView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: 200)
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [.allowUserInteraction], animations: { [weak self] in
            self?.containerView.transform = CGAffineTransform.identity
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [.allowUserInteraction], animations: { [weak self] in
            self?.containerView.transform = CGAffineTransform.identity.scaledBy(x: 0.8, y: 0.8)
        })
    }
    
    @objc func didTapBackground() {
        dismiss(animated: true)
    }
    
    func updateColors() {
        visualEffectView.effect = blurEffect
    }
}
