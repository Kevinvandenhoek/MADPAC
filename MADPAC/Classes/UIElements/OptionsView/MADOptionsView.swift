//
//  MADOptionsView.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 05/08/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import EasyPeasy

protocol MADOptionsViewDelegate: AnyObject {
    func didSelect(sender: MADOptionsView, option: String)
    func didToggleCollapse(sender: MADOptionsView, collapse: Bool)
    func setCurrentSetting(on sender: MADOptionsView)
}

class MADOptionsView: MADView, ColorUpdatable {
    
    let titleLabel = MADLabel(style: .custom)
    let currentSettingLabel = MADLabel(style: .custom)
    let arrowImageView = UIImageView(image: UIImage(named: "arrow_collapse_expand")?.withRenderingMode(.alwaysTemplate))
    var isCollapsed: Bool = true
    
    let collapseGestureView = UIView()
    var options: [String] = []
    var optionButtons: [MADOptionsButton] = []
    var preferredHeight: CGFloat { return isCollapsed
        ? headerHeight
        : headerHeight + CGFloat(optionButtons.count) * optionHeight
    }
    
    private let headerHeight: CGFloat = 50
    private let optionHeight: CGFloat = 40
    
    weak var delegate: MADOptionsViewDelegate?
    
    override func setup() {
        super.setup()
        
        layer.cornerRadius = 8
        
        addSubview(collapseGestureView)
        collapseGestureView.easy.layout([Left(), Top(), Right(), Height(headerHeight)])
        collapseGestureView.backgroundColor = .clear
        collapseGestureView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCollapse)))
        
        addSubview(titleLabel)
        titleLabel.font = UIFont(fontStyle: .regular, size: 18)
        titleLabel.easy.layout([Left(17), Top(), Height(headerHeight)])
        
        addSubview(currentSettingLabel)
        currentSettingLabel.font = UIFont(fontStyle: .light, size: 18)
        currentSettingLabel.easy.layout([Left(7).to(titleLabel), CenterY().to(titleLabel)])
        
        addSubview(arrowImageView)
        arrowImageView.contentMode = .center
        arrowImageView.easy.layout([Size(headerHeight), CenterY().to(titleLabel), Right()])
        
        updateColors()
        renderState()
    }
    
    func update(with option: MADOptionItem) {
        titleLabel.text = option.title
        options = option.options
        updateButtons()
        renderState()
        delegate?.setCurrentSetting(on: self)
    }
    
    @objc func didTapCollapse() {
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [.allowUserInteraction], animations: { [weak self] in
            guard let `self` = self else { return }
            if self.isCollapsed { self.expand() } else { self.collapse() }
            //self.optionButtons.forEach({ $0.alpha = self.isCollapsed ? 0 : 1 })
            self.layoutIfNeeded()
        }) { (_) in
            // Nothing yet
        }
        delegate?.didToggleCollapse(sender: self, collapse: !isCollapsed)
    }
    
    @objc func didTapOption(sender: MADButton) {
        guard let option = sender.title else { return }
        delegate?.didSelect(sender: self, option: option)
    }
    
    func updateColors() {
        collapseGestureView.backgroundColor = UIColor.MAD.UIElements.optionsBackground
        
        titleLabel.textColor = isCollapsed ? UIColor.MAD.UIElements.secondaryText : UIColor.MAD.UIElements.primaryText
        currentSettingLabel.textColor = UIColor.MAD.UIElements.tertiaryText
        arrowImageView.tintColor = UIColor.MAD.UIElements.subtleTint
        for button in optionButtons {
            button.updateColors()
        }
    }
    
    func renderState() {
        arrowImageView.transform = !isCollapsed ? CGAffineTransform.identity : CGAffineTransform.identity.scaledBy(x: 1, y: -1)
        for button in optionButtons {
            button.setSelected(button.title == currentSettingLabel.text)
        }
    }
    
    func displayOption(index: Int) {
        
    }
}

extension MADOptionsView {
    func expand() {
        guard isCollapsed else { return }
        titleLabel.easy.clear()
        titleLabel.easy.layout([CenterX(), Top(), Height(headerHeight)])
        currentSettingLabel.alpha = 0
        isCollapsed = false
        updateColors()
        renderState()
    }
    
    func collapse() {
        guard !isCollapsed else { return }
        currentSettingLabel.alpha = 1
        titleLabel.easy.clear()
        titleLabel.easy.layout([Left(17), Top(), Height(headerHeight)])
        isCollapsed = true
        updateColors()
        renderState()
    }
    
    func updateButtons() {
        for button in optionButtons {
            button.removeTarget(self, action: #selector(didTapOption), for: .touchUpInside)
            button.removeFromSuperview()
        }
        
        var lastButton: UIView?
        for (index, option) in options.enumerated() {
            let button = MADOptionsButton()
            addSubview(button)
            button.easy.layout([Left(), Right(), Height(optionHeight - 1)])
            button.title = option
            button.titleLabel?.font = UIFont(fontStyle: .regular, size: 14)
            button.addTarget(self, action: #selector(didTapOption), for: .touchUpInside)
            if let lastButton = lastButton {
                button.easy.layout([Top(1).to(lastButton)])
            } else {
                button.easy.layout([Top(1).to(titleLabel)])
            }
            optionButtons.append(button)
            lastButton = button
            if index == options.count - 1 {
                button.easy.layout([Left(), Right(), Height(optionHeight + 10)])
                button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
            }
        }
    }
}

