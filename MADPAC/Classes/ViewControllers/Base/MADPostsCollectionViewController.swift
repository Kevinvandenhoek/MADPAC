//
//  MADPostsCollectionViewController.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 30/05/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import Foundation
import UIKit
import EasyPeasy

class MADPostsCollectionViewController: MADPostsViewController {
    
    private var didInitialLoad: Bool = false
    private(set) var loadingOverlay: MADLoadingOverlay?
    var loadingIndicatorOffset: CGFloat { return 0 }
    class var cellCornerRadius: CGFloat { return 4 }
    private(set) var lastScrollViewOffset: CGFloat?
    private let pullToReloadDistance: CGFloat = 100
    
    let loadingBottomView = MADLoadingBottomBar()
    
    private(set) var storedTransitionedCell: NavigationTransitioningView?
    
    // If we have a loading cell, use these when there is no content
    var loadingCellType: MADBaseLoadingCollectionViewCell.Type? { return nil }
    
    let preloadNextFrom: Int = 5
    let loadingCellCount: Int = 14
    
    var cellSpacing: CGFloat { return 7.5 }
    var cellPadding: CGFloat { return 7.5 }
    var cellsPerRow: CGFloat { return 1 }
    
    let collectionView: MADCollectionView = MADCollectionView()
    var collectionViewUpdater: CollectionViewUpdater<MADPost>?
    
    override func setup() {
        super.setup()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        refreshControl = UIRefreshControl()
        collectionView.refreshControl = refreshControl
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        collectionViewUpdater = CollectionViewUpdater<MADPost>(for: collectionView, and: self)
        
        loadingBottomView.delegate = self
        
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.showTabBar(animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func add(posts: [MADPost]) {
        collectionViewUpdater?.add(items: posts)
    }
    
    private func cellTypeToDequeue(for indexPath: IndexPath) -> MADBaseCollectionViewCell.Type? {
        if indexPath.item >= posts.count {
            return loadingCellType(for: indexPath)
        } else {
            return cellTypeFor(indexPath: indexPath)
        }
    }
    
    func cellTypeFor(indexPath: IndexPath) -> MADPostCollectionViewCell.Type {
        return MADPostCollectionViewCell.self
    }
    
    func loadingCellType(for: IndexPath) -> MADBaseLoadingCollectionViewCell.Type? {
        return loadingCellType
    }
    
    private func registerCellType(type: UICollectionViewCell.Type) {
        collectionView.register(type, forCellWithReuseIdentifier: type.description())
    }
    
    override func handleLoadingState(_ isLoading: Bool) {
        if isLoading {
            guard !(posts.count > 0), !view.subviews.contains(where: { $0 is MADLoadingOverlay }) else { return }
            loadingOverlay = MADLoadingOverlay()
            view.addSubview(loadingOverlay!)
            loadingOverlay?.indicatorOffsetY = self.loadingIndicatorOffset
            loadingOverlay?.easy.layout([Edges()])
            loadingOverlay?.startLoading()
        } else {
            loadingBottomView.showLoading(false)
            loadingOverlay?.stopLoading(completion: { [weak self] (completed) in
                guard let `self` = self else { return }
                self.loadingOverlay?.removeFromSuperview()
                self.loadingOverlay = nil
                self.didInitialLoad = true
            })
        }
    }
    
    override func allows(view: UIView) -> Bool {
        return storedTransitionedCell?.allows(view: view) == true
    }

    override func getTransitioningView<T>() -> T? where T : UIView {
        return storedTransitionedCell?.getTransitioningView() as? T
    }
    
    override func getTargetRect() -> CGRect? {
        guard let cell = storedTransitionedCell as? UIView, let cellOriginRect = storedTransitionedCell?.getTargetRect() else { return nil }
        let translatedFrame = collectionView.convert(cell.frame, to: collectionView.superview)
        let originCellFrame = view.convert(translatedFrame, to: view.superview)
        let originFrame = CGRect(x: originCellFrame.minX + cellOriginRect.minX, y: originCellFrame.minY + cellOriginRect.minY, width: cellOriginRect.width, height: cellOriginRect.height)
        return originFrame
    }
    
    override func receive(transitionedView: UIView) {
        guard let storedCell = storedTransitionedCell else {
            transitionedView.removeFromSuperview()
            return
        }
        storedCell.receive(transitionedView: transitionedView)
    }
    
    override func endTransition(presenting: Bool, completed: Bool) {
        super.endTransition(presenting: presenting, completed: completed)
        storedTransitionedCell?.endTransition(presenting: presenting, completed: completed)
        if !presenting && completed || presenting && !completed {
            storedTransitionedCell = nil
        }
    }
    
    func storeForTransition(_ cell: UICollectionViewCell) -> NavigationTransitioningView? {
        guard let transitioningView = cell as? NavigationTransitioningView else { return nil }
        self.storedTransitionedCell = transitioningView
        return transitioningView
    }
    
    func cellFor(collectionView: UICollectionView, indexPath: IndexPath, cellType: UICollectionViewCell.Type) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType.reuseIdentifier, for: indexPath)
        if let postUpdatableCell = cell as? PostUpdatable, let post = posts[safe: indexPath.item] {
            postUpdatableCell.update(with: post)
        }
        return cell
    }
    
    override func updateColors() {
        super.updateColors()
        
        collectionView.visibleCells.compactMap({ $0 as? ColorUpdatable }).forEach({ $0?.updateColors() })
        loadingBottomView.updateColors()
        loadingOverlay?.updateColors()
    }
}

// MARK: View setup
extension MADPostsCollectionViewController {
    func setupViews() {
        view.addSubview(collectionView)
        collectionView.easy.layout([Edges()])
        
        view.addSubview(loadingBottomView)
        let tabBarHeight = getTabBarHeight()
        let bottomViewHeight: CGFloat = min(50, tabBarHeight)
        loadingBottomView.isUserInteractionEnabled = false
        loadingBottomView.easy.layout([
            Left(),
            Bottom(),
            Right(),
            Height(bottomViewHeight)])
    }
}

// CollectionView Delegate
extension MADPostsCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: cellPadding, left: cellPadding, bottom: cellPadding, right: cellPadding)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let cellHeight = cellTypeToDequeue(for: indexPath)?.cellHeight else {
            return CGSize.zero
        }
        let totalCellsWidth: CGFloat = (collectionView.frame.width - (CGFloat(cellsPerRow + 1) * cellPadding))
        return CGSize(width: totalCellsWidth / cellsPerRow, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? MADBaseCollectionViewCell else { return }
        cell.willAppear()
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? MADBaseCollectionViewCell else { return }
        cell.willDisappear()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = posts[safe: indexPath.row],
              let cell = collectionView.cellForItem(at: indexPath) else {
            return
        }
        
        if let storedView = storeForTransition(cell) {
            if storedView.getTransitioningView() is TransformingVideoPlayerView {
                navigationController?.pushViewController(MADVideoDetailViewController(from: item), animated: true)
            } else if storedView.getTransitioningView() is TransformingImageView {
                navigationController?.pushViewController(MADArticleDetailViewController(from: item), animated: true)
            }
        }
    }
}

// CollectionView DataSource
extension MADPostsCollectionViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let category = category else { return 0 }
        return posts.count + (loadingCellType != nil ? loadingCellCount : 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let collectionView = collectionView as? MADCollectionView else {
            return UICollectionViewCell()
        }
        
        if (indexPath.item) > (posts.count - preloadNextFrom) && !isLoading {
            fetchPosts()
            loadingBottomView.showLoading(true)
        }
        
        guard let cellType: UICollectionViewCell.Type = cellTypeToDequeue(for: indexPath) else {
            return UICollectionViewCell()
        }
        
        collectionView.registerIfNeeded(cellType.self)
        let cell = cellFor(collectionView: collectionView, indexPath: indexPath, cellType: cellType.self)
        return cell
    }
}

extension MADPostsCollectionViewController: CollectionViewUpdaterDelegate {
    func getCurrentItems<T: Equatable>() -> [T] {
        return posts.compactMap({ $0 as? T })
    }
    
    func appendToItems<T: Equatable>(itemsToAppend: [T]) {
        guard let category = category else { return }
        let itemsToAppend = itemsToAppend.compactMap({ (post) -> MADPost? in
            return post as? MADPost
        })
        posts += itemsToAppend
    }
    
    func removeFromItems<T: Equatable>(itemsToRemove: [T]) {
        let postsToRemove = itemsToRemove.compactMap({ (post) -> MADPost? in
            return post as? MADPost
        })
        let indexes = postsToRemove.compactMap({ posts.firstIndex(of: $0) }).sorted(by: { $0 > $1 })
        for index in indexes.sorted(by: { $0 > $1 }) {
            posts.remove(at: index)
        }
    }
    
    func didCompleteUpdates() {
        // Nothing
    }
}

extension MADPostsCollectionViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard self.isVisible else { return }
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
        
        let overshoot = abs(scrollView.contentOffset.y) - (scrollView.contentSize.height - scrollView.frame.size.height)
        let totalLerpedDistance = getTabBarHeight(includingSafeArea: false)
        if overshoot > 0 && posts.count > 0 {
            // reached the bottom
            let lerpAmount = overshoot / totalLerpedDistance
            loadingBottomView.lerpVisibility(lerpAmount, distance: totalLerpedDistance)
            
            let pullAmount = overshoot - totalLerpedDistance
            let lerp = pullAmount / pullToReloadDistance
            loadingBottomView.lerpPullToReload(lerp)
        } else {
            loadingBottomView.setVisibility(false, animated: false)
        }
    }
}

extension MADPostsCollectionViewController: MADLoadingBottomBarDelegate {
    func didRequestRefresh(sender: MADLoadingBottomBar) {
        fetchPosts()
    }
}
