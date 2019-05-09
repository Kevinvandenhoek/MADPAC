//
//  MADSimpleAPIWrapper.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 30/05/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import Foundation

class MADSimpleAPIWrapper {
    
    static var shared: MADSimpleAPIWrapper { return MADSimpleAPIWrapper() }
    
    func getPosts(for vc: MADBaseViewController, category: String?, page: Int, result: @escaping ([MADPost]?) -> Void) {
        let startTime = Date().timeIntervalSince1970
        
        MADSimpleAPI.request(with: "get_category_posts", parameters: [
            "category": category ?? "trending",
            "page": "\(page)",
            "app": "true"
        ]) { (data) in
            guard let data = data else {
                result(nil)
                return
            }
            let postsWrapper = try? JSONDecoder().decode(MADPostsWrapper.self, from: data)
            guard let wrappedPosts = postsWrapper?.data?.posts else {
                let dataString = String(data: data, encoding: String.Encoding.utf8) ?? data.description
                print("Could not parse data for get_category_posts page \(page) and \(category ?? ""), data: \(dataString)")
                result(nil)
                return
            }
            var posts: [MADPost] = []
            for post in wrappedPosts {
                posts.append(MADPost(from: post))
            }
            let endTime = Date().timeIntervalSince1970 - startTime
            print("Got posts in \(endTime) sec")
            result(posts)
        }
    }
        
    func getCategories(for vc: MADBaseViewController, result: @escaping ([MADCategory]?) -> Void) {
        let startTime = Date().timeIntervalSince1970
        MADSimpleAPI.request(with: "get_categories", parameters: [:], completion: { (data) in
            guard let data = data else {
                result(nil)
                return
            }
            let categoriesWrapper = try? JSONDecoder().decode(MADCategoriesWrapper.self, from: data)
            guard let wrappedCategories = categoriesWrapper?.data?.categories else { return }
            var categories: [MADCategory] = []
            for category in wrappedCategories {
                guard let title = category.title else { continue }
                guard self.categoryIsAllowed(category.slug) else { continue }
                categories.append(title)
            }
            let endTime = Date().timeIntervalSince1970 - startTime
            print("Got categories in \(endTime) sec")
            result(categories)
        })
    }
    
    func search(term: String, for vc: MADBaseViewController, result: @escaping ([MADPost]?) -> Void) {
        let startTime = Date().timeIntervalSince1970
        
        MADSimpleAPI.request(with: "search", parameters: ["q" : term]) { (data) in
            guard let data = data else {
                result(nil)
                return
            }
            let postsWrapper = try? JSONDecoder().decode(MADPostsWrapper.self, from: data)
            guard let wrappedPosts = postsWrapper?.data?.posts else {
                let dataString = String(data: data, encoding: String.Encoding.utf8) ?? data.description
                print("Could not parse data for get_category_posts, data: \(dataString)")
                result(nil)
                return
            }
            var posts: [MADPost] = []
            for post in wrappedPosts {
                posts.append(MADPost(from: post))
            }
            let endTime = Date().timeIntervalSince1970 - startTime
            print("Got posts in \(endTime) sec")
            result(posts)
        }
    }
    
    func getAppInit(result: @escaping (MADAppInit?) -> Void) {
        let startTime = Date().timeIntervalSince1970
        
        MADSimpleAPI.getAppInit { (data) in
            guard let data = data else {
                result(nil)
                return
            }
            let appInit = try? JSONDecoder().decode(MADAppInit.self, from: data)
            let endTime = Date().timeIntervalSince1970 - startTime
            print("Got appInit in \(endTime) sec")
            result(appInit)
        }
    }
}

extension MADSimpleAPIWrapper {
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
