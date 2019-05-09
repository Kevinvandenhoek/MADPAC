//
//  MADVideoViewController.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 29/05/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import AVKit

class MADVideoViewController: MADPostsCollectionViewController, TopBarPage, AudioControllerPage {
    
    var videoView: MADVideoView? { return videoTopView.playerView.videoView }
    var controlsView: MADVideoControlsView? { return videoTopView.playerView.controlsView }
    
    var vc: UIViewController { return self }
    
    override var category: String? { return "video" }
    
    override var loadingIndicatorOffset: CGFloat { return videoTopView.baseHeight / 2 }
    override var reloadViewYOffset: CGFloat { return videoTopView.baseHeight / 2 }
    
    var audioObserver: NSKeyValueObservation?
    
    
    var selectedVideoPost: MADPost?
    lazy var topView: MADTopView = { return MADVideoTopView() }()
    var videoTopView: MADVideoTopView { return topView as! MADVideoTopView }
    var bottomView: MADVideoBottomView = { return MADVideoBottomView() }()
    var scrollView: UIScrollView { return collectionView as UIScrollView }
    var topBarPageDelegate: MADTopBarPageDelegate?
    
    override func cellTypeFor(indexPath: IndexPath) -> MADPostCollectionViewCell.Type {
        return MADVideoArticleCollectionViewCell.self
    }
    
    override func setup() {
        super.setup()
        
        videoTopView.delegate = self
        
        if let madNavigationController = navigationController as? MADNavigationViewController {
            madNavigationController.handleTopPage(for: self)
            madNavigationController.updateTopBarOffset(to: 0)
            madNavigationController.setTopBarAlpha(to: 1)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        videoTopView.delegate = self
        videoTopView.playerView.delegate = self
        
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
        
        videoTopView.playerView.delegate = nil
        audioObserver?.invalidate()
        audioObserver = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        controlsView?.playButton.fixBlur()
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        guard self.isVisible else { return }
        topBarPageDelegate?.scrollViewDidScroll(scrollView, bottomInset: getTabBarHeight(), topInset: getNavigationBarHeight() + topView.baseHeight)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let post = posts[safe: indexPath.row], MADVideo(from: post) != nil, selectedVideoPost != post else {
            return
        }
        open(post)
    }
    
    override func add(posts: [MADPost]) {
        if videoTopView.currentVideo == nil, let videoPost = posts.first(where: { MADVideo(from: $0) != nil }) {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.open(videoPost, play: UserPreferences.autoPlay && self.isVisible)
            }
        }
        super.add(posts: posts)
    }
    
    func open(_ post: MADPost, play: Bool = true) {
        if let currentPost = selectedVideoPost {
            getCellFor(post: currentPost)?.displayCurrentlyPlaying(false)
        }
        self.selectedVideoPost = post
        videoTopView.open(post, play: play)
        topBarPageDelegate?.expand()
        getCellFor(post: post)?.displayCurrentlyPlaying(true)
    }
    
    override func didSetPosts() {
        super.didSetPosts()
        
        if let currentPost = selectedVideoPost {
            getCellFor(post: currentPost)?.displayCurrentlyPlaying(true)
        }
    }
    
    deinit {
        print("Deinit \(String(describing: self))")
        audioObserver?.invalidate()
        audioObserver = nil
    }
    
    override func updateColors() {
        super.updateColors()
        videoTopView.updateColors()
    }
    
    private func getCellFor(post: MADPost) -> MADVideoArticleCollectionViewCell? {
        guard let index = posts.firstIndex(of: post) else { return nil }
        return collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? MADVideoArticleCollectionViewCell
    }
    
    override func cellFor(collectionView: UICollectionView, indexPath: IndexPath, cellType: UICollectionViewCell.Type) -> UICollectionViewCell {
        let cell = super.cellFor(collectionView: collectionView, indexPath: indexPath, cellType: cellType)
        (cell as? MADVideoArticleCollectionViewCell)?.displayCurrentlyPlaying(posts[safe: indexPath.row] == selectedVideoPost)
        return cell
    }
}

extension MADVideoViewController: TabbedPage {
    
    var tabImage: UIImage { return #imageLiteral(resourceName: "tabbar_video") }
    var pageTitle: String { return "VIDEO" }
    var tabTitle: String? { return pageTitle }
    
    func becameSelectedTab() {
        videoTopView.playerView.videoView.player?.play()
    }
    
    func becameDeselectedTab() {
        videoTopView.playerView.videoView.player?.pause()
    }
}

extension MADVideoViewController: MADVideoTopViewDelegate {

    func didTapBottomBar() {
        guard let selectedVideoPost = selectedVideoPost else { return }
        let videoTabDetailVC = MADVideoTabDetailViewController(from: selectedVideoPost, with: self)
        if let navigationController = navigationController {
            navigationController.pushViewController(videoTabDetailVC, animated: true)
        }
    }
}

extension MADVideoViewController: MADVideoTabDetailViewControllerDelegate {
    func getTopView() -> MADTopView {
        return topView
    }
    
    func getViewController() -> UIViewController {
        return vc
    }
}

extension MADVideoViewController: MADVideoPlayerDelegate {
    func getVC() -> UIViewController {
        return self
    }
    
    func playbackStatusChanged(to status: MADVideoView.PlaybackStatus) {
        // TODO
    }
    
    func didFinishPlaying() {
        if let currentVideoId = selectedVideoPost?.id {
            if let nextVideoIndex = posts.index(where: { (otherPost) -> Bool in
                guard let id = otherPost.id else { return false }
                let isNext = id < currentVideoId
                return isNext
            }), let newVideo = posts[safe: nextVideoIndex] {
                open(newVideo)
            }
        }
    }
}
