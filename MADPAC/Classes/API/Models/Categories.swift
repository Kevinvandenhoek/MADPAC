//
//  Categories.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 29/05/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import Foundation

struct MADCategoriesWrapper: Codable {
    let status: Int?
    let method: String?
    let message: String?
    let data: MADCategoriesAPIModel?
    
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case method = "method"
        case message = "message"
        case data = "data"
    }
}

struct MADCategoriesAPIModel: Codable {
    let categories: [MADCategoryAPIModel]?
    
    enum CodingKeys: String, CodingKey {
        case categories = "posts"
    }
}

struct MADCategoryAPIModel: Codable {
    let id: Int?
    let slug: String?
    let title: String?
    let tabBar: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case slug = "slug"
        case title = "title"
        case tabBar = "tab_bar"
    }
}
