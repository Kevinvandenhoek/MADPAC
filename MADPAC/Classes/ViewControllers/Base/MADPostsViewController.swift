//
//  MADPostsViewController.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 29/05/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit
import EasyPeasy

class MADPostsViewController: MADBaseViewController {
    
    var category: String? { return nil }
    private var _page: [String: Int] = [:]
    private var page: Int {
        get {
            guard let category = category else { return 1 }
            return _page[category] ?? 1
        }
        set {
            guard let category = category else { return }
            _page[category] = newValue
        }
    }
    
    var reloadViewController: ReloadViewController?
    var refreshControl: UIRefreshControl?
    
    var loading: Bool = false {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.handleLoadingState(self?.loading == true)
            }
        }
    }
    var isLoading: Bool {
        return loading
    }
    
    private var _posts: [String: [MADPost]] = [:] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.didSetPosts()
            }
        }
    }
    var posts: [MADPost] {
        get {
            return _posts[category ?? ""] ?? []
        }
        set(newValue) {
            guard let category = category else { return }
            self._posts[category] = newValue.sorted(by: {
                $0.id ?? 0 > $1.id ?? 0
            })
        }
    }
    
    var reloadViewYOffset: CGFloat { return 0 }
    
    override func initialize() {
        super.initialize()
        
        fetchPosts()
    }
    
    func fetchPosts() {
        guard !isLoading, let category = category else { return }
        hideReloadVCIfNeeded()
        loading = true
        MADSimpleAPIWrapper.shared.getPosts(for: self, category: category, page: page) { [weak self] (posts) in
            self?.loading = false
            guard let self = self else { return }
            guard let posts = posts, posts.count > 0 else {
                if self.posts.count <= 0 {
                    self.showReloadViewController()
                }
                return
            }
            self.add(posts: posts.compactMap({ self.posts.contains($0) == true ? nil : $0 }))
            self.page += 1
        }
    }
    
    @objc func refresh() {
        guard let category = category else { return }
        MADSimpleAPIWrapper.shared.getPosts(for: self, category: category, page: 1) { [weak self] (posts) in
            self?.refreshControl?.endRefreshing()
            guard let `self` = self, let posts = posts else {
                return
            }
            let filteredPosts = posts.compactMap({ self.posts.contains($0) == true ? nil : $0 })
            self.add(posts: filteredPosts)
        }
    }
    
    func add(posts: [MADPost]) {
        self.posts += posts
    }
    
    func didSetPosts() {
        // Override
    }
    
    func handleLoadingState(_ isLoading: Bool) {
        // Override
    }
    
    func showReloadViewController() {
        guard reloadViewController == nil else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.reloadViewController == nil else { return }
            let reloadVC = ReloadViewController(delegate: self, offset: self.reloadViewYOffset)
            self.reloadViewController = reloadVC
            
            self.view.addSubview(reloadVC.view)
            reloadVC.view.easy.layout([Edges()])
            self.addChildViewController(reloadVC)
            reloadVC.fadeIn()
        }
    }
    
    override func updateColors() {
        super.updateColors()
        
        reloadViewController?.updateColors()
    }
    
    func hideReloadVCIfNeeded(completion: (() -> Void)? = nil) {
        guard let reloadVC = reloadViewController else { return }
        reloadVC.reloadButton.isEnabled = false
        reloadVC.fadeOut(completion: { [weak self] in
            guard let self = self else { return }
            reloadVC.view.removeFromSuperview()
            self.remove(childController: reloadVC)
            self.reloadViewController = nil
            completion?()
        })
    }
}

extension MADPostsViewController: ReloadViewControllerDelegate {
    func didTapRetry() {
        hideReloadVCIfNeeded { [weak self] in
            self?.fetchPosts()
        }
    }
}
