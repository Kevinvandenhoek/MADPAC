//
//  MADAPIWrapper.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 29/05/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import Foundation
import TIFNetwork
import TIFExtensions
import RxSwift

class MADAPIWrapper {
    static var shared: MADAPIWrapper { return MADAPIWrapper() }
    
    func getCategories(for vc: MADBaseViewController, result: @escaping ([MADCategory]?) -> Void) {
        let startTime = Date().timeIntervalSince1970
        MADAPI.getCategories()
            .request()
            .map(MADCategoriesWrapper.self)
            .doOnNext { (categoriesWrapper) in
                guard let wrappedCategories = categoriesWrapper.data?.categories else { return }
                var categories: [MADCategory] = []
                for category in wrappedCategories {
                    guard let title = category.title else { continue }
                    guard self.categoryIsAllowed(category.slug) else { continue }
                    categories.append(title)
                }
                let endTime = startTime - Date().timeIntervalSince1970
                print("Got categories in \(endTime) sec")
                result(categories)
            }
            .doOnError { (error) in
                result(nil)
            }
            .observeOn(MainScheduler.instance)
            .subscribe()
            .disposed(by: vc.disposeBag)
    }
    
    func getPosts(for vc: MADBaseViewController, category: String?, result: @escaping ([MADPost]?) -> Void) {
        let startTime = Date().timeIntervalSince1970
        MADAPI.getPosts(category: category, page: 1)
            .request()
            .map(MADPostsWrapper.self)
            .doOnNext { (postsWrapper) in
                guard let wrappedPosts = postsWrapper.data?.posts else { return }
                var posts: [MADPost] = []
                for post in wrappedPosts {
                    posts.append(MADPost(from: post))
                }
                let endTime = startTime - Date().timeIntervalSince1970
                print("Got posts in \(endTime) sec")
                result(posts)
            }
            .doOnError { (error) in
                result(nil)
            }
            .observeOn(MainScheduler.instance)
            .subscribe()
            .disposed(by: vc.disposeBag)
    }
    
    func getSearch(for vc: MADBaseViewController, term: String, result: @escaping ([MADPost]?) -> Void) {
        let startTime = Date().timeIntervalSince1970
        MADAPI.getSearch(term: term)
            .request()
            .map(MADPostsWrapper.self)
            .doOnNext { (postsWrapper) in
                guard let wrappedPosts = postsWrapper.data?.posts else { return }
                var posts: [MADPost] = []
                for post in wrappedPosts {
                    posts.append(MADPost(from: post))
                }
                let endTime = startTime - Date().timeIntervalSince1970
                print("Got posts in \(endTime) sec")
                result(posts)
            }
            .doOnError { (error) in
                result(nil)
            }
            .observeOn(MainScheduler.instance)
            .subscribe()
            .disposed(by: vc.disposeBag)
    }
}

extension MADAPIWrapper {
    
    func categoryIsAllowed(_ categorySlug: String?) -> Bool {
        guard let category = categorySlug?.lowercased() else { return false }
        let notAllowedCategories: [String] = ["uncategorized", "video", "interviews", "photo"]
        for notAllowedCategory in notAllowedCategories {
            if category == notAllowedCategory {
                return false
            }
        }
        return true
    }
}
