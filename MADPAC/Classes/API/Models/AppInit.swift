//
//  AppInit.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 31/10/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import Foundation

struct MADAppInit: Codable {
    let status: String?
    let count: Int?
    let menuLocation, menuID: String?
    let menu: [MADMenuItem?]?
    
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case count = "count"
        case menuLocation = "menu_location"
        case menuID = "menu_id"
        case menu = "menu"
    }
}

struct MADMenuItem: Codable {
    let id: Int?
    let active, parentID: String?
    let menuOrder: Int?
    let label, slug, objectType, objectID: String?
    let url: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case active = "active"
        case parentID = "parent_id"
        case menuOrder = "menu_order"
        case label = "label"
        case slug = "slug"
        case objectType = "object_type"
        case objectID = "object_id"
        case url = "url"
    }
}
