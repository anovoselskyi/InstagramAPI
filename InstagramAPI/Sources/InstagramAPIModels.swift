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
  
    public var token: String

    public var userId: Int
}

public struct User: Codable {
  
    public var id: String

    public var username: String
}

public struct Feed: Codable {
  
    public var data: [MediaData]
    
    public var paging: PagingData
}

public struct MediaData: Codable {
  
    public var id: String
    
    public var caption: String?
}

public struct PagingData: Codable {
  
    public var cursors: CursorData
    
    public var next: String
}

public struct CursorData: Codable {
  
    public var before: String
    
    public var after: String
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
  
    public var id: String
    
    public var mediaType: MediaType
    
    public var mediaUrl: String
    
    public var thumbnailUrl: String?
    
    public var username: String
    
    public var timestamp: String
}
