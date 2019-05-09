//
//  ReloadViewController.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 31/10/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import EasyPeasy

protocol ReloadViewControllerDelegate: AnyObject {
    func didTapRetry()
}

class ReloadViewController: MADBaseViewController {
    
    var blurEffect: UIVisualEffect { return UIBlurEffect(style: UserPreferences.darkMode ? .dark : .extraLight) }
    let blurView: UIVisualEffectView = UIVisualEffectView(effect: nil)
    let reloadButton: MADHighlightedButton = MADHighlightedButton()
    let reloadLabel: UILabel = MADLabel(style: .custom)
    let reloadDescription: UILabel = MADLabel(style: .custom)
    
    var offset: CGFloat = 0
    
    weak var delegate: ReloadViewControllerDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    init(delegate: ReloadViewControllerDelegate, offset: CGFloat = 0) {
        super.init()
        self.delegate = delegate
        self.offset = offset
    }
    
    override func initialize() {
        super.initialize()
        
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }
    
    override func setup() {
        super.setup()
        
        view.addSubview(blurView)
        view.addSubview(reloadButton)
        view.addSubview(reloadLabel)
        view.addSubview(reloadDescription)
        
        blurView.easy.layout([Edges()])
        reloadButton.easy.layout([CenterX(), Width(140), Height(40)])
        reloadDescription.easy.layout([CenterX(), Width(240), CenterY(offset), Bottom(14).to(reloadButton, .top)])
        reloadLabel.easy.layout([CenterX(), Width(240), Bottom(3).to(reloadDescription, .top)])
        
        reloadLabel.text = "🤔"
        reloadLabel.font = UIFont.MAD.avenirMedium(size: 36)
        reloadLabel.textAlignment = .center
        
        reloadDescription.text = "Oeps, er ging iets mis met het ophalen van de content. Onze excuses hiervoor! Probeer je het opnieuw?"
        reloadDescription.font = UIFont.MAD.avenirLight(size: 13)
        reloadDescription.textAlignment = .center
        reloadDescription.numberOfLines = 0
        
        reloadButton.setTitle("PROBEER OPNIEUW", for: .normal)
        reloadButton.addTarget(self, action: #selector(didTapRetry), for: .touchUpInside)
        
        show(false)
    }
    
    override func updateColors() {
        super.updateColors()
        
        view.backgroundColor = .clear
        
        blurView.effect = (blurView.effect == nil) ? nil : blurEffect
        reloadLabel.textColor = UIColor.MAD.UIElements.primaryText
        reloadDescription.textColor = UIColor.MAD.UIElements.secondaryText
        reloadButton.updateColors()
    }
    
    @objc func didTapRetry() {
        delegate?.didTapRetry()
    }
    
    func fadeIn() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.show(true)
        })
    }
    
    func fadeOut(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.show(false)
        }) { (_) in
            completion()
        }
    }
    
    private func show(_ show: Bool) {
        blurView.effect = show ? blurEffect : nil
        reloadLabel.alpha = show ? 1 : 0
        reloadDescription.alpha = show ? 1 : 0
        reloadButton.alpha = show ? 1 : 0
    }
}
