//
//  MADVideoTabDetailViewController.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 21/07/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import AVFoundation

protocol MADVideoTabDetailViewControllerDelegate: AnyObject {
    func getTopView() -> MADTopView // To pass it by reference
    func getViewController() -> UIViewController // To pass it by reference
}

class MADVideoTabDetailViewController: MADDetailViewController, TopBarPage {
    
    override var hidesNavigationBarTitle: Bool { return false }
    
    var topView: MADTopView { return delegate.getTopView() }
    var videoTopView: MADVideoTopView { return topView as! MADVideoTopView }
    var scrollView: UIScrollView { return self.webView.scrollView }
    var topBarPageDelegate: MADTopBarPageDelegate?
    var vc: UIViewController { return delegate.getViewController() }
    var didAppear: Bool = false
    
    override var baseHeaderHeight: CGFloat { return videoTopView.baseHeight }
    
    private var delegate: MADVideoTabDetailViewControllerDelegate
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Does not support init(coder)")
    }
    
    init(from post: MADPost, with delegate: MADVideoTabDetailViewControllerDelegate) {
        self.delegate = delegate
        super.init(from: post)
    }
    
    override func setup() {
        super.setup()
        view.backgroundColor = UIColor.MAD.UIElements.pageBackground
        webView.alpha = 0
        webView.scrollView.delegate = self
    }
    
    override func allows(view: UIView) -> Bool {
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (delegate.getTopView() as? MADVideoTopView)?.delegate = self
        
        UIView.animate(withDuration: 0.3, delay: 0.1, options: [.curveEaseIn], animations: { [weak self] in
            self?.webView.alpha = 1
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didAppear = true
        
        guard audioObserver == nil else { return }
        audioObserver = AVAudioSession.sharedInstance().observe( \.outputVolume ) { [weak self] (av, _) in
            guard let `self` = self else { return }
            self.updateForVolume(av.outputVolume)
            UserPreferences.session.muteVideo = av.outputVolume == 0
        }
        videoView?.playbackMode = UserPreferences.session.muteVideo ? .silent : .normal
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        audioObserver?.invalidate()
        audioObserver = nil
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        if didAppear {
            // The scrollViewDidScroll does only work properly on full screen (frame minY = 0) scrollViews, so we compensate for the non 0 minY from the webview in the passed 'topInset' when we have the webview laid out differently (to fix apples contentinset webkitview bug)
            let topInset: CGFloat = (getNavigationBarHeight() + topView.baseHeight) - webView.frame.minY
            topBarPageDelegate?.scrollViewDidScroll(scrollView, bottomInset: getTabBarHeight(), topInset: topInset)
        }
    }
    
    deinit {
        print("Deinit \(String(describing: self))")
        audioObserver?.invalidate()
        audioObserver = nil
    }
}

extension MADVideoTabDetailViewController: MADVideoTopViewDelegate {
    func didFinishPlaying() {
        return
    }
    
    func didTapBottomBar() {
        return
    }
}
