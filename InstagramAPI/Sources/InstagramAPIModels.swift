//
//  InstagramResponse.swift
//  InstagramAPI
//
//  Created by Andrii Novoselskyi on 17.04.2020.
//

import Foundation

public struct UserAccessToken: Codable {
    
    enum CodingKeys: String, CodingKey {
        
        case token = "access_token"

        case userId = "user_id"
    }
  
    var token: String

    var userId: Int
}

public struct User: Codable {
  
    var id: String

    var username: String
}

public struct Feed: Codable {
  
    var data: [MediaData]
    
    var paging: PagingData
}

public struct MediaData: Codable {
  
    var id: String
    
    var caption: String?
}

public struct PagingData: Codable {
  
    var cursors: CursorData
    
    var next: String
}

public struct CursorData: Codable {
  
    var before: String
    
    var after: String
}

public enum MediaType: String, Codable {
  
    case image = "IMAGE"
    
    case video = "VIDEO"
    
    case album = "CAROUSEL_ALBUM"
}

public struct Media: Codable {
    
    enum CodingKeys: String, CodingKey {
        
        case id

        case mediaType = "media_type"

        case mediaUrl = "media_url"

        case thumbnailUrl = "thumbnail_url"

        case username

        case timestamp
    }
  
    var id: String
    
    var mediaType: MediaType
    
    var mediaUrl: String
    
    var thumbnailUrl: String?
    
    var username: String
    
    var timestamp: String
}
