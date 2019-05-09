//
//  MADSearchViewController.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 04/08/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//  

import UIKit
import EasyPeasy

protocol MADSearchViewControllerDelegate: AnyObject {
    func getSearchBar() -> MADSearchBar
    func getClearButton() -> MADButton
}

class MADSearchViewController: MADPostsCollectionViewController, SearchEnabledPage {
    
    override var hidesNavigationBarTitle: Bool { return true }
    
    weak var delegate: MADSearchViewControllerDelegate?
    let recentSearchView = RecentSearchView()
    
    private var currentTerm: String?
    
    override var category: String? { return "search" }
    
    let noResultLabel: MADLabel = MADLabel(style: .custom)
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard self.posts.count == 0 else { return }
        recentSearchView.show(animated: true)
    }
    
    override func prepareForTransition(presenting: Bool, isTargetVc: Bool, transitionProperties: TransitionProperties) {
        if isTargetVc {
            self.view.backgroundColor = presenting ? UIColor.clear : UIColor.MAD.UIElements.pageBackground
            self.view.alpha = presenting ? 0 : 1
            self.recentSearchView.alpha = presenting ? 0 : 1
        }
    }
    
    override func animateInTransition(presenting: Bool, isTargetVc: Bool) {
        self.view.backgroundColor = isTargetVc ? UIColor.MAD.UIElements.pageBackground : UIColor.clear
        self.recentSearchView.alpha = isTargetVc ? 1 : 0
        self.view.alpha = isTargetVc ? 1 : 0
    }
    
    override func setup() {
        super.setup()
        
        view.addSubview(recentSearchView)
        recentSearchView.easy.layout([Left(), Top(getNavigationBarHeight()), Right(), Bottom(getTabBarHeight())])
        recentSearchView.delegate = self
        
        view.addSubview(noResultLabel)
        noResultLabel.easy.layout([Left(70), Top(getNavigationBarHeight()), Right(70), Bottom(getTabBarHeight())])
        noResultLabel.numberOfLines = 0
        noResultLabel.font = UIFont(fontStyle: .regular, size: 17)
        noResultLabel.textColor = UIColor.MAD.UIElements.secondaryText
        noResultLabel.textAlignment = .center
        noResultLabel.text = nil
    }
    
    override func fetchPosts() {
        // Nothing
    }
    
    func fetchForSearchTerm(_ term: String?) {
        guard !isLoading, let term = term, term.trimmingCharacters(in: CharacterSet(charactersIn: "!@#$%^&*`~;:'\"<,>.?/[{]}\\|-_=+")) != "" else { return }
        self.noResultLabel.text = nil
        currentTerm = term
        if !UserDefaults.standard.searchHistory.contains(where: { $0 == term }) {
            UserDefaults.standard.searchHistory.append(term)
        }
        loading = true
        self.posts = []
        collectionView.reloadData()
        delegate?.getClearButton().alpha = 1
        recentSearchView.hide(animated: true)
        delegate?.getSearchBar().textField.resignFirstResponder()
        delegate?.getSearchBar().textField.text = term
        MADSimpleAPIWrapper.shared.search(term: term, for: self) { [weak self] (posts) in
            guard let self = self else { return }
            self.loading = false
            guard self.currentTerm == term else { return }
            if let posts = posts, posts.count > 0 {
                self.add(posts: posts.compactMap({ self.posts.contains($0) == true ? nil : $0 }))
            } else { // Got no results
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.noResultLabel.text = "Geen resultaten gevonden voor '\(term)'"
                }
            }
        }
    }
    
    func clearContent() {
        posts = []
        self.loading = false
        self.currentTerm = nil
        self.noResultLabel.text = nil
        self.collectionView.reloadWith { [weak self] in
            self?.recentSearchView.show(animated: true)
        }
    }
}

extension MADSearchViewController: RecentSearchViewDelegate {
    func didTapTerm(_ term: String?) {
        guard let term = term, term != "" else { return }
        fetchForSearchTerm(term)
    }
}
