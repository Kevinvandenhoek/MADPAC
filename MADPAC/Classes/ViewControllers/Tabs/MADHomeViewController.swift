//
//  MADHomeViewController.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 29/05/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import EasyPeasy
import AVFoundation

final class MADHomeViewController: MADPostsCollectionViewController, TopBarPage, SearchEnabledPage {
    
    weak var topBarPageDelegate: MADTopBarPageDelegate?
    var vc: UIViewController { return self }
    
    lazy var topView: MADTopView = { return PostCategoryTopBarView(with: self) }()
    override var category: String? { return (topView as! PostCategoryTopBarView).segmentedControl.selectedItem?.lowercased() }
    
    var scrollView: UIScrollView { return collectionView as UIScrollView }
    
    private var startupOverlay: MADStartupOverlay?
    
    private var activeVideoViews: [MADVideoCollectionViewCell] = []
    
    override func setup() {
        super.setup()
        
        startupOverlay = MADStartupOverlay()
        view.addSubview(startupOverlay!)
        startupOverlay?.layer.zPosition = 1
        startupOverlay?.easy.layout([Edges()])
        startupOverlay?.displayAdjustedColors()
        
        (collectionView as UIScrollView).delegate = self
        
        if let madNavigationController = navigationController as? MADNavigationViewController {
            madNavigationController.handleTopPage(for: self)
            madNavigationController.updateTopBarOffset(to: 0)
            madNavigationController.setTopBarAlpha(to: 1)
        }
        setupCategories()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startupOverlay?.fadeOut(completion: { [weak self] (completed) in
            guard let `self` = self else { return }
            self.startupOverlay?.removeFromSuperview()
            self.startupOverlay = nil
        })
        
        if UserPreferences.autoPlay {
            resumeActivePlayers()
        }
        
        if !UserPreferences.userDidSeeThemePopover || UserPreferences.forceThemePopover {
            let popoverVC = MADThemePopoverViewController()
            present(popoverVC, animated: true) {
                UserPreferences.userDidSeeThemePopover = true
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        pauseActivePlayers()
    }
    
    func setupCategories() {
        if let storedCategories = UserDefaults.standard.categories {
            (topView as? PostCategoryTopBarView)?.setup(with: storedCategories)
            fetchPosts()
        }
        MADAPIWrapper.shared.getCategories(for: self) { [weak self] (categories) in
            let categories = categories?.compactMap({ $0.uppercased() })
            if categories != UserDefaults.standard.categories {
                (self?.topView as? PostCategoryTopBarView)?.setup(with: categories)
                UserDefaults.standard.categories = categories
                self?.fetchPosts()
            }
        }
    }
    
    override func cellTypeFor(indexPath: IndexPath) -> MADPostCollectionViewCell.Type {
        guard let post = posts[safe: indexPath.item] else {
            return MADArticleCollectionViewCell.self
        }
        
        switch post.postType {
        case .article:
            return MADArticleCollectionViewCell.self
        case .video:
            return MADVideoCollectionViewCell.self
        case .gallery:
            return MADGalleryCollectionViewCell.self
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        guard self.isVisible else { return }
        topBarPageDelegate?.scrollViewDidScroll(scrollView, bottomInset: getTabBarHeight(), topInset: getNavigationBarHeight() + topView.baseHeight)
    }
    
    override func cellFor(collectionView: UICollectionView, indexPath: IndexPath, cellType: UICollectionViewCell.Type) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType.reuseIdentifier, for: indexPath)
        (cell as? MADVideoCollectionViewCell)?.delegate = self
        if let postUpdatableCell = cell as? PostUpdatable, let post = posts[safe: indexPath.item] {
            postUpdatableCell.update(with: post)
        }
        return cell
    }
    
    func pauseActivePlayers() {
        activeVideoViews.forEach({
            guard $0 !== (storedTransitionedCell as? MADVideoCollectionViewCell) else { return }
            $0.transformingVideoView?.videoView.player?.pause()
        })
    }

    func resumeActivePlayers() {
        activeVideoViews.forEach({ $0.transformingVideoView?.videoView.player?.play() })
    }
}

extension MADHomeViewController: TabbedPage {
    
    var tabImage: UIImage { return #imageLiteral(resourceName: "tabbar_home") }
    var pageTitle: String { return "HOME" }
    var tabTitle: String? { return pageTitle }
}

extension MADHomeViewController: PostCategoryTopBarViewDelegate {
    
    func didSelect(category: String?) {
        hideReloadVCIfNeeded()
        collectionView.reloadWith { [weak self] in
            guard let self = self else { return }
            if self.posts.count <= 0 {
                self.fetchPosts()
            } else {
                self.loading = false
                self.handleLoadingState(false)
                self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: UICollectionViewScrollPosition.centeredVertically, animated: false)
            }
        }
    }
}

extension MADHomeViewController: MADVideoCollectionViewCellDelegate {
    func startedPlaying(videoCell: MADVideoCollectionViewCell) {
        guard !activeVideoViews.contains(videoCell) else { return }
        activeVideoViews.append(videoCell)
    }
    
    func stoppedPlaying(videoCell: MADVideoCollectionViewCell) {
        guard let index = activeVideoViews.index(where: { $0 == videoCell }) else { return }
        activeVideoViews.remove(at: index)
    }
}
