//
//  MADPost
//  Madpac
//
//  Created by Kevin van den Hoek on 29/05/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import Foundation

struct MADPost: Equatable, Hashable {
    let title: String?
    let category: MADCategory?
    let date: String?
    let thumbnailImageUrl: String?
    let imageUrl: String?
    let postType: PostType
    let videoUrl: String?
    let videoType: MADVideoType?
    let id: Int?
    let htmlContent: String?
    
    enum PostType {
        case article
        case video
        case gallery
    }
    
    init(from post: MADPostModel) {
        title = post.title
        category = post.category?.name
        date = post.releaseDate
        thumbnailImageUrl = post.image?.medium?.url
        imageUrl = post.image?.large?.url
        videoUrl = post.videoSrc
        id = post.id
        htmlContent = post.content
        
        
        // Set post type
        switch post.type {
        case "article":
            postType = .article
        case "video":
            postType = .video
        case "gallery":
            postType = .gallery
        default:
            postType = .article
        }
        
        // Set video type
        switch post.videoType?.lowercased() {
        case "youtube":
            videoType = .youtube
        case "vimeo":
            videoType = .vimeo
        default:
            videoType = .none
        }
    }
    
    static func == (lhs: MADPost, rhs: MADPost) -> Bool {
        return lhs.id == rhs.id
    }
    
    var hashValue: Int {
        return self.id?.hashValue ?? 0
    }
}
