//
//  MADMoreViewController.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 29/05/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import EasyPeasy

struct MADOptionItem {
    let title: String
    let options: [String]
}

struct MADLink {
    let title: String
    let link: URL?
}

class MADMoreViewController: MADBaseViewController {
    
    let scrollView = UIScrollView()
    let containerView = MADView()
    
    let logoImageView = MADImageView(image: UIImage(named: "logo_madpac")?.withRenderingMode(.alwaysTemplate))
    
    let options: [MADOptionItem] = [
        MADOptionItem(title: "Thema", options: ["Donker", "Licht"]),
        MADOptionItem(title: "HD Video", options: [
            DataUsagePreference.high.rawValue,
            //DataUsagePreference.wifi.rawValue,
            DataUsagePreference.low.rawValue
            ]),
        MADOptionItem(title: "Autoplay", options: [
            DataUsagePreference.high.rawValue,
            //DataUsagePreference.wifi.rawValue,
            DataUsagePreference.low.rawValue
            ]),
//        MADOptionItem(title: "Dev: Force show theme popup", options: [
//            "Aan",
//            "Uit"
//            ])
    ]
    let links: [MADLink] = [
        MADLink(title: "Over ons", link: URL(string: "http://www.madpac.nl/p/over-ons")),
        MADLink(title: "Contact", link: URL(string: "http://www.madpac.nl/p/contact")),
        MADLink(title: "Adverteren", link: URL(string: "http://www.madpac.nl/p/adverteren")),
        MADLink(title: "Disclaimer", link: URL(string: "http://www.madpac.nl/p/disclaimer")),
        MADLink(title: "Privacy Statement", link: URL(string: "http://www.madpac.nl/p/privacy")),
        MADLink(title: "Copyright", link: URL(string: "http://www.madpac.nl/p/copyright")),
        MADLink(title: "Notice & Take Down", link: URL(string: "http://www.madpac.nl/p/notice-en-take"))
    ]
    var linkButtons: [MADLinkButton] = []
    var optionsViews: [MADOptionsView] = []
    
    override func setup() {
        super.setup()
        
        view.addSubview(scrollView)
        scrollView.easy.layout([Edges()])
        
        scrollView.addSubview(containerView)
        containerView.easy.layout([Width().like(scrollView), CenterX(), Top()])
        if #available(iOS 11.0, *) { scrollView.contentInsetAdjustmentBehavior = .never }
        scrollView.contentInset = UIEdgeInsets(top: getNavigationBarHeight(), left: 0, bottom: getTabBarHeight(), right: 0)
        
        containerView.addSubview(logoImageView)
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.easy.layout([Top(46), Height(50), Left(), Right()])
        logoImageView.isUserInteractionEnabled = true
        logoImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapLogo)))
        
        addOptions()
        view.layoutIfNeeded()
    }
    
    @objc func didTapLogo() {
        UserPreferences.pinkMadpacLogo = !UserPreferences.pinkMadpacLogo
        updateColors()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.contentSize = containerView.bounds.size
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        collapseAllViews()
        scrollView.scrollToTop()
    }
    
    func addOptions() {
        var lastOption: UIView?
        for option in options {
            let optionsView = MADOptionsView()
            containerView.addSubview(optionsView)
            optionsView.delegate = self
            optionsView.easy.layout([Left(8), Right(8), Height(50)])
            if let lastOption = lastOption {
                optionsView.easy.layout([Top(8).to(lastOption)])
            } else {
                optionsView.easy.layout([Top(46).to(logoImageView, .bottom)])
            }
            optionsView.update(with: option)
            optionsViews.append(optionsView)
            lastOption = optionsView
        }
        var lastLink: MADLinkButton?
        for (index, link) in links.enumerated() {
            let linkButton = MADLinkButton()
            let isLast = index == (links.count - 1)
            containerView.addSubview(linkButton)
            linkButton.easy.layout([Left(8), Right(8), Height(50)])
            linkButton.layer.cornerRadius = 8
            if let lastLink = lastLink {
                linkButton.easy.layout([Top(8).to(lastLink)])
            } else {
                linkButton.easy.layout([Top(46).to(optionsViews.last!, .bottom)])
            }
            if isLast {
                linkButton.easy.layout([Bottom(46)])
            }
            linkButton.update(with: link)
            linkButtons.append(linkButton)
            lastLink = linkButton
        }
    }
    
    override func updateColors() {
        super.updateColors()
        
        logoImageView.tintColor = UIColor.MAD.UIElements.logoColor
        optionsViews.forEach({ $0.updateColors() })
        linkButtons.forEach({ $0.updateColors() })
    }
    
    func collapseAllViews() {
        optionsViews.forEach({
            $0.collapse()
            $0.easy.layout([Height($0.preferredHeight)])
        })
        self.view.layoutIfNeeded()
        self.scrollView.contentSize = self.containerView.bounds.size
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        for optionsView in containerView.subviews.compactMap({ $0 as? MADOptionsView }) {
            setCurrentSetting(on: optionsView)
        }
        
        var animationItems: [UIView] = []
        animationItems.append(logoImageView)
        animationItems += optionsViews.compactMap({ $0 as UIView })
        animationItems += linkButtons.compactMap({ $0 as UIView })
        for (index, item) in animationItems.enumerated() {
            let delay = index == 0 ? 0.1 : Double(index) * 0.03
            fadeIn(item, delay: delay)
        }
    }
    
    private func fadeIn(_ view: UIView, delay: Double) {
        view.alpha = 0
        view.transform = CGAffineTransform.identity.scaledBy(x: 0.7, y: 0.7)
        UIView.animate(withDuration: 0.7, delay: delay, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [.allowUserInteraction], animations: {
            view.alpha = 1
            view.transform = CGAffineTransform.identity
        })
    }
}

extension MADMoreViewController: TabbedPage {
    
    var tabImage: UIImage { return #imageLiteral(resourceName: "tabbar_more") }
    var pageTitle: String { return "" }
    var tabTitle: String? { return nil }
}

extension MADMoreViewController: MADOptionsViewDelegate {
    func didToggleCollapse(sender: MADOptionsView, collapse: Bool) {
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [.allowUserInteraction], animations: { [weak self] in
            guard let `self` = self else { return }
            for optionView in self.optionsViews {
                if optionView != sender { optionView.collapse() }
                optionView.easy.layout([Height(optionView.preferredHeight)])
            }
            self.view.layoutIfNeeded()
            self.scrollView.contentSize = self.containerView.bounds.size
        })
    }
    
    func didSelect(sender: MADOptionsView, option: String) {
        if sender.titleLabel.text == "Thema" {
            if option == "Donker" { UserPreferences.darkMode = true } else { UserPreferences.darkMode = false }
        } else if sender.titleLabel.text == "HD Video" {
            switch option {
            case DataUsagePreference.high.rawValue:
                UserPreferences.videoQualityPreference = .high
            case DataUsagePreference.wifi.rawValue:
                UserPreferences.videoQualityPreference = .wifi
            default:
                UserPreferences.videoQualityPreference = .low
            }
        } else if sender.titleLabel.text == "Autoplay" {
            switch option {
            case DataUsagePreference.high.rawValue:
                UserPreferences.autoPlayPreference = .high
            case DataUsagePreference.wifi.rawValue:
                UserPreferences.autoPlayPreference = .wifi
            default:
                UserPreferences.autoPlayPreference = .low
            }
        } else if sender.titleLabel.text == "Dev: Force show theme popup" {
            UserPreferences.forceThemePopover = option == "Aan"
        }
        setCurrentSetting(on: sender)
    }
    
    func setCurrentSetting(on sender: MADOptionsView) {
        if sender.titleLabel.text == "Thema" {
            sender.currentSettingLabel.text = UserPreferences.darkMode ? "Donker" : "Licht"
        } else if sender.titleLabel.text == "HD Video" {
            sender.currentSettingLabel.text = UserPreferences.videoQualityPreference?.rawValue ?? DataUsagePreference.low.rawValue
        } else if sender.titleLabel.text == "Autoplay" {
            sender.currentSettingLabel.text = UserPreferences.autoPlayPreference?.rawValue ?? DataUsagePreference.low.rawValue
        } else if sender.titleLabel.text == "Dev: Force show theme popup" {
            sender.currentSettingLabel.text = UserPreferences.forceThemePopover ? "Aan" : "Uit"
        }
        sender.renderState()
    }
}
