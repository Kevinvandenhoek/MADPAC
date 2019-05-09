//
//  RecentSearchView.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 04/08/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import EasyPeasy

protocol RecentSearchViewDelegate: AnyObject {
    func didTapTerm(_ term: String?)
}

class RecentSearchView: MADView {
    
    let scrollView = UIScrollView()
    let topGradientImageView = UIImageView(image: UIImage(named: "search_recent_topgradient")!.withRenderingMode(.alwaysTemplate))
    let recentSearchesLabel = MADLabel(style: .custom)
    let clearSearchesButton = MADButton()
    let scrollContainerView = MADView()
    
    private let noRecentSearchesText: String = "Geen recente zoekopdrachten"
    private let clearSearchHistoryText: String = "Wis zoekgeschiedenis"
    
    private let baseOffset: CGFloat = 65
    private let buttonHeight: CGFloat = 35
    private let animationDelayPerItem: CGFloat = 0.03
    
    var recentSearchButtons: [MADButton] = []
    var recentSearches: [String] = []
    
    var isShown: Bool = false
    
    weak var delegate: RecentSearchViewDelegate?
    
    override func setup() {
        super.setup()
        
        addSubview(scrollView)
        scrollView.easy.layout([Edges()])
        
        scrollView.addSubview(scrollContainerView)
        scrollContainerView.frame = CGRect(x: 0, y: 0, width: frame.width, height: 2500)
        scrollContainerView.backgroundColor = .clear
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 220, right: 0)
        
        addSubview(topGradientImageView)
        topGradientImageView.easy.layout([Left(), Right(), Top(), Height(topGradientImageView.image!.size.height)])
        
        addSubview(recentSearchesLabel)
        recentSearchesLabel.easy.layout([Top(20), Height(40), Left(30), Right(30)])
        recentSearchesLabel.textAlignment = .center
        recentSearchesLabel.font = UIFont(fontStyle: .regular, size: 18)
        recentSearchesLabel.text = nil
        
        updateColors()
        hide(animated: false)
    }
    
    func hide(animated: Bool) {
        isShown = false
        if animated {
            for (index, button) in self.recentSearchButtons.enumerated() {
                self.fadeViewOut(button, delay: CGFloat(index) * self.animationDelayPerItem)
            }
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let `self` = self else { return }
                self.recentSearchesLabel.alpha = 0
                self.topGradientImageView.alpha = 0
            }
        } else {
            recentSearchesLabel.alpha = 0
            recentSearchButtons.forEach({ $0.alpha = 0 })
            topGradientImageView.alpha = 0
        }
        isUserInteractionEnabled = false
    }
    
    func show(animated: Bool) {
        // TODO: Show animation logic
        isShown = true
        recentSearches = UserDefaults.standard.searchHistory.reversed() // most recent up top
        displayRecentSearches()
        isUserInteractionEnabled = true
        self.topGradientImageView.alpha = 1
    }
    
    func displayRecentSearches() {
        clearCurrentButtons()
        
        recentSearchesLabel.text = recentSearches.count > 0 ? "Recent" : noRecentSearchesText
        fadeViewIn(recentSearchesLabel, delay: 0)
        for (index, term) in recentSearches.enumerated() {
            let button = MADButton()
            recentSearchButtons.append(button)
            fadeViewIn(button, delay: CGFloat(index) * animationDelayPerItem)
            button.titleLabel?.font = UIFont(fontStyle: .light, size: 14)
            button.title = term
            button.addTarget(self, action: #selector(didTapTerm), for: .touchUpInside)
            scrollContainerView.addSubview(button)
            button.easy.layout([Left(), Right(), Top(baseOffset + (CGFloat(index) * buttonHeight)), Height(buttonHeight)])
        }
        addClearButton()
        updateColors()
        updateScrollViewContentSize()
    }
    
    func fadeViewIn(_ view: UIView, delay: CGFloat) {
        view.alpha = 0
        view.transform = CGAffineTransform.identity.scaledBy(x: 0.7, y: 0.7)
        UIView.animate(withDuration: 0.3, delay: Double(delay), options: [.allowUserInteraction], animations: {
            view.alpha = 1
            view.transform = CGAffineTransform.identity
        })
    }
    
    func fadeViewOut(_ view: UIView, delay: CGFloat) {
        UIView.animate(withDuration: 0.3, delay: Double(delay), options: [.allowUserInteraction], animations: {
            view.alpha = 0
            view.transform = CGAffineTransform.identity.scaledBy(x: 0.7, y: 0.7)
        })
    }
    
    func addClearButton() {
        guard recentSearches.count > 0 else { return }
        let button = MADButton()
        button.titleLabel?.font = UIFont(fontStyle: .bold, size: 14)
        button.title = clearSearchHistoryText
        button.addTarget(self, action: #selector(didTapTerm), for: .touchUpInside)
        scrollContainerView.addSubview(button)
        button.easy.layout([Left(), Right(), Top(baseOffset + (CGFloat(recentSearchButtons.count) * buttonHeight)), Height(buttonHeight)])
        button.frame = CGRect(x: 0, y: baseOffset + (CGFloat(recentSearchButtons.count) * buttonHeight), width: width, height: buttonHeight)
        recentSearchButtons.append(button)
        fadeViewIn(button, delay: CGFloat(recentSearchButtons.count) * animationDelayPerItem)
    }
    
    func clearCurrentButtons() {
        recentSearchButtons.forEach({
            $0.removeTarget(self, action: #selector(didTapTerm(sender:)), for: UIControl.Event.touchUpInside)
            $0.removeFromSuperview()
            recentSearchButtons.remove(object: $0)
        })
    }
    
    @objc func didTapTerm(sender: MADButton) {
        guard sender.title != clearSearchHistoryText else {
            recentSearches = []
            UserDefaults.standard.searchHistory = []
            displayRecentSearches()
            return
        }
        delegate?.didTapTerm(sender.title)
    }
    
    override var frame: CGRect {
        didSet {
            updateScrollViewContentSize()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateScrollViewContentSize()
    }
    
    func updateScrollViewContentSize() {
        scrollContainerView.frame = CGRect(x: 0, y: 0, width: frame.width, height: (recentSearchButtons.last?.frame.maxY ?? 0) + 50)
        scrollView.contentSize = CGSize(width: scrollContainerView.frame.width, height: scrollContainerView.height)
    }
}

extension RecentSearchView: ColorUpdatable {
    func updateColors() {
        topGradientImageView.tintColor = UIColor.MAD.UIElements.pageBackground
        recentSearchesLabel.textColor = UIColor.MAD.UIElements.secondaryText
        
        recentSearchButtons.forEach({ $0.setTitleColor(UIColor.MAD.UIElements.secondaryText, for: .normal) })
        recentSearchButtons.last?.setTitleColor(UIColor.MAD.hotPink, for: .normal)
    }
}
