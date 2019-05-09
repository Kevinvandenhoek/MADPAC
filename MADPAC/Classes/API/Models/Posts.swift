// To parse the JSON, add this file to your project and do:
//
//   let empty = try? JSONDecoder().decode(Empty.self, from: jsonData)

import Foundation

struct MADPostsWrapper: Codable {
    let status: Int?
    let method: String?
    let message: String?
    let count: Int?
    let countTotal: String?
    let pages: Int?
    let page: String?
    let data: MADPostsModel?
    
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case method = "method"
        case message = "message"
        case count = "count"
        case countTotal = "count_total"
        case pages = "pages"
        case page = "page"
        case data = "data"
    }
}

struct MADPostsModel: Codable {
    let posts: [MADPostModel]?
    
    enum CodingKeys: String, CodingKey {
        case posts = "posts"
    }
}

struct MADPostModel: Codable {
    
    let id: Int?
    let type: String?
    let advertorial: Bool?
    let slug: String?
    let title: String?
    let author: String?
    let image: Image?
    let spotifyURL: Bool?
    let allCategories: [Category]?
    let category: Category?
    let releaseDate: String?
    let content: String?
    let videoType: String?
    let videoSrc: String?
    let excerpt: String?
    //let related: [MADRelatedPost]?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case advertorial = "advertorial"
        case slug = "slug"
        case title = "title"
        case author = "author"
        case image = "image"
        case spotifyURL = "spotify_url"
        case allCategories = "all_categories"
        case category = "category"
        case releaseDate = "release_date"
        case content = "content"
        case videoType = "video_type"
        case videoSrc = "video_src"
        case excerpt = "excerpt"
        //case related = "related"
    }
}

struct MADRelatedPost: Codable {
    let id: Int?
    let advertorial: Bool?
    let slug: String?
    let title: String?
    let spotifyURL: Bool?
    let category: Category?
    let releaseDate: String?
    let excerpt: String?
    let galleryCount: Int?
    let allCategories: [Category]?
    let content: String?
    let videoSrc: String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case advertorial = "advertorial"
        case slug = "slug"
        case title = "title"
        case spotifyURL = "spotify_url"
        case category = "category"
        case releaseDate = "release_date"
        case excerpt = "excerpt"
        case galleryCount = "gallery_count"
        case allCategories = "all_categories"
        case content = "content"
        case videoSrc = "video_src"
    }
}

struct Category: Codable {
    let id: Int?
    let name: String?
    let slug: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case slug = "slug"
    }
}

struct Image: Codable {
    let title: String?
    let alt: String?
    let thumb: Large?
    let medium: Large?
    let large: Large?
    let tablet: Large?
    
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case alt = "alt"
        case thumb = "thumb"
        case medium = "medium"
        case large = "large"
        case tablet = "tablet"
    }
}

struct Large: Codable {
    let file: String?
    let width: Int?
    let height: Int?
    let mimeType: String?
    let url: String?
    
    enum CodingKeys: String, CodingKey {
        case file = "file"
        case width = "width"
        case height = "height"
        case mimeType = "mime-type"
        case url = "url"
    }
}
