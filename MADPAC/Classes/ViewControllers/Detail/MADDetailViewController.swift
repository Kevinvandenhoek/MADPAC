//
//  MADDetailViewController.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 15/07/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import EasyPeasy
import WebKit
import AVFoundation

class MADDetailViewController: MADBaseViewController, AudioControllerPage {
    
    var videoView: MADVideoView? {
        if let videoView = (headerView as? MADDetailVideoHeaderView)?.transformingVideoView?.videoView {
            return videoView
        } else if let transformingImageView = headerView?.transformingImageView, transformingImageView.videoPlayerView.isHidden == false {
            return transformingImageView.videoPlayerView.videoView
        } else {
            return nil
        }
    }
    var controlsView: MADVideoControlsView? {
        if let videoView = (headerView as? MADDetailVideoHeaderView)?.transformingVideoView {
            return videoView.controlsView
        } else if let transformingImageView = headerView?.transformingImageView, transformingImageView.videoPlayerView.isHidden == false {
            return transformingImageView.videoPlayerView.controlsView
        } else {
            return nil
        }
    }
    
    private var webViewAnimationOffset: CGFloat = 0
    
    override var hidesNavigationBarTitle: Bool { return true }
    
    var audioObserver: NSKeyValueObservation?
    
    var didInitialAppear: Bool = false
    var post: MADPost?
    var lastScrollViewOffset: CGFloat?
    var extraTopOffset: CGFloat { return 0 }
    var headerView: MADDetailHeaderView?
    var baseHeaderHeight: CGFloat { return UIScreen.main.bounds.width / (4 / 3) }
    var minimumHeaderHeight: CGFloat? { return (videoView != nil) ? (UIScreen.main.bounds.width / (16 / 9)) : nil }
    var baseHeaderFrame: CGRect {
        if let headerFrame = headerView?.frame, headerFrame != CGRect.zero {
            let minOffset = -(headerFrame.height)
            if headerFrame.minY < minOffset {
                return CGRect(x: headerFrame.minX, y: minOffset, width: headerFrame.width, height: headerFrame.height)
            } else {
                return headerFrame
            }
        } else {
            return CGRect(x: 0, y: headerOffset, width: UIScreen.main.bounds.width, height: baseHeaderHeight)
        }
    }
    private lazy var headerOffset: CGFloat = {
        return getNavigationBarHeight()
    }()
    
    let webView = MADWebView()
    var webviewIsSmallerThanFrame: Bool = true
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(from post: MADPost) {
        super.init()
        update(with: post)
    }
    
    override func setup() {
        super.setup()
        
        layoutViews()
        setupViews()
    }
    
    override func allows(view: UIView) -> Bool {
        return headerView?.allows(view: view) == true
    }
    
    override func receive(transitionedView: UIView) {
        headerView?.receive(transitionedView: transitionedView)
    }
    
    override func getTargetRect() -> CGRect? {
        return baseHeaderFrame
    }
    
    override func getTransitioningView<T>() -> T? where T : UIView {
        return headerView?.getTransitioningView()
    }
    
    override func prepareForTransition(presenting: Bool, isTargetVc: Bool, transitionProperties: TransitionProperties) {
        super.prepareForTransition(presenting: presenting, isTargetVc: isTargetVc, transitionProperties: transitionProperties)
        webViewAnimationOffset = transitionProperties.fromFrame.maxY - transitionProperties.toFrame.maxY
        if presenting {
            view.backgroundColor = .clear
            headerView?.transformingImageView?.alpha = 0
            webView.alpha = 0
            webView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: webViewAnimationOffset)
        } else {
            view.backgroundColor = UIColor.MAD.UIElements.pageBackground
        }
    }
    
    override func animateInTransition(presenting: Bool, isTargetVc: Bool) {
        if presenting {
            view.backgroundColor = UIColor.MAD.UIElements.pageBackground
            webView.alpha = 1
            webView.transform = CGAffineTransform.identity
        } else {
            view.backgroundColor = .clear
            webView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: webViewAnimationOffset)
            webView.alpha = 0
        }
    }
    
    override func endTransition(presenting: Bool, completed: Bool) {
        super.endTransition(presenting: presenting, completed: completed)
        guard let headerView = headerView, completed else { return }
        
        headerView.transformingImageView?.alpha = 1
        view.backgroundColor = UIColor.MAD.UIElements.pageBackground
        webView.transform = CGAffineTransform.identity
        
        if presenting {
        } else {
            webView.alpha = 1
        }
    }
    
    func updateWebviewScrollInsets() {
        let safeAreaBottom = getSafeAreaInsets().bottom
        let topInset = headerOffset + baseHeaderHeight + extraTopOffset
        let bottomInset = safeAreaBottom
        if webviewIsSmallerThanFrame {
            webView.easy.layout([Top(topInset), Bottom(bottomInset)])
            webView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else {
            webView.easy.layout([Top(), Bottom()])
            webView.scrollView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: bottomInset, right: 0)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didInitialAppear = true
        
        guard audioObserver == nil else { return }
        audioObserver = AVAudioSession.sharedInstance().observe( \.outputVolume ) { [weak self] (av, _) in
            guard let `self` = self else { return }
            self.updateForVolume(av.outputVolume)
            UserPreferences.session.muteVideo = av.outputVolume == 0
        }
        
        // Update right now, not only after changes
        let av = AVAudioSession.sharedInstance()
        updateForVolume(UserPreferences.session.muteVideo ? 0.0 : av.outputVolume)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        audioObserver?.invalidate()
        audioObserver = nil
    }
    
    override func updateColors() {
        super.updateColors()
        
        if didInitialAppear, let post = self.post {
            update(with: post)
        }
    }
    
    deinit {
        print("Deinit \(String(describing: self))")
        audioObserver?.invalidate()
        audioObserver = nil
    }
}

// View setup
extension MADDetailViewController {
    
    func layoutViews() {
        view.addSubview(webView)
        webView.easy.layout([Edges()])
        
        guard let headerView = headerView else { return }
        view.addSubview(headerView)
        headerView.easy.layout([Left(), Top(headerOffset), Right(), Height(baseHeaderHeight)])
    }
    
    func setupViews() {
        webView.scrollView.delegate = self
        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        }
        webView.backgroundColor = UIColor.clear
        webView.scrollView.backgroundColor = UIColor.clear
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.isOpaque = false
        webView.clipsToBounds = false
        webView.scrollView.clipsToBounds = false
        webView.delegate = self
        updateWebviewScrollInsets()
    }
}

// View updating
extension MADDetailViewController {
    func update(with post: MADPost) {
        guard let html = HTMLHelper.shared.getHtmlFor(post: post) else { return }
        self.post = post
        webView.loadHTMLString(html, baseURL: nil)
    }
}

extension MADDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isTransitioning else { return }
        let offset = -(scrollView.contentOffset.y + (scrollView.contentInset.top))
        
        // Handle tabbar hiding/showing
        if let lastScrollViewOffset = lastScrollViewOffset, scrollView.panGestureRecognizer.state == .changed {
            if lastScrollViewOffset > offset { // Scrolling down
                tabBarController?.hideTabBar(animated: true)
            } else if lastScrollViewOffset < offset { // Scrolling up
                tabBarController?.showTabBar(animated: true)
            }
        }
        lastScrollViewOffset = offset
        
        // Handle the headerview offsetting
        if let headerView = headerView {
            let topOffset = offset + headerOffset
            if headerOffset < topOffset {
                let extraHeight = topOffset - headerOffset
                headerView.easy.layout([Height(baseHeaderHeight + extraHeight), Top(headerOffset)])
            } else {
                let height = baseHeaderHeight + offset
                if let minimumHeaderHeight = minimumHeaderHeight {
                    if height >= minimumHeaderHeight {
                        headerView.easy.layout([Height(height), Top(headerOffset)])
                    } else {
                        headerView.easy.layout([Height(minimumHeaderHeight), Top(headerOffset)])
                    }
                } else {
                    headerView.easy.layout([Height(baseHeaderHeight), Top(topOffset)])
                }
            }
        }
    }
}

extension MADDetailViewController: MADWebViewDelegate {
    func didChangeContentSize(to size: CGSize) {
        let isSmaller = size.height < view.frame.height
        if isSmaller != webviewIsSmallerThanFrame {
            webviewIsSmallerThanFrame = isSmaller
            updateWebviewScrollInsets()
        }
    }
}
