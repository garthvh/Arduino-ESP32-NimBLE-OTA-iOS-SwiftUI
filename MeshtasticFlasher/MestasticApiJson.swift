//
//  MestasticApiJson.swift
//  MeshtasticFlasherESP32
//
//  Created by Garth Vander Houwen on 3/10/23.
//

import Foundation

struct FirmwareRelease: Codable {
    
    var releases     : Releases?       = Releases()
    var pullRequests : [PullRequests]? = []
    
    enum CodingKeys: String, CodingKey {
        
        case releases     = "releases"
        case pullRequests = "pullRequests"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        releases     = try values.decodeIfPresent(Releases.self       , forKey: .releases     )
        pullRequests = try values.decodeIfPresent([PullRequests].self , forKey: .pullRequests )
    }
    
    init() {
        
    }
}

struct Releases: Codable {
    
    var stable : [Stable]? = []
    var alpha  : [Alpha]?  = []
    
    enum CodingKeys: String, CodingKey {
        
        case stable = "stable"
        case alpha  = "alpha"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        stable = try values.decodeIfPresent([Stable].self , forKey: .stable )
        alpha  = try values.decodeIfPresent([Alpha].self  , forKey: .alpha  )
    }
    
    init() {
        
    }
}

struct Alpha: Codable {
    
    var id      : String? = nil
    var title   : String? = nil
    var pageUrl : String? = nil
    var zipUrl  : String? = nil
    
    enum CodingKeys: String, CodingKey {
        
        case id      = "id"
        case title   = "title"
        case pageUrl = "page_url"
        case zipUrl  = "zip_url"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id      = try values.decodeIfPresent(String.self , forKey: .id      )
        title   = try values.decodeIfPresent(String.self , forKey: .title   )
        pageUrl = try values.decodeIfPresent(String.self , forKey: .pageUrl )
        zipUrl  = try values.decodeIfPresent(String.self , forKey: .zipUrl  )
    }
    
    init() {
        
    }
}

struct Stable: Codable {
    
    var id      : String? = nil
    var title   : String? = nil
    var pageUrl : String? = nil
    var zipUrl  : String? = nil
    
    enum CodingKeys: String, CodingKey {
        
        case id      = "id"
        case title   = "title"
        case pageUrl = "page_url"
        case zipUrl  = "zip_url"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id      = try values.decodeIfPresent(String.self , forKey: .id      )
        title   = try values.decodeIfPresent(String.self , forKey: .title   )
        pageUrl = try values.decodeIfPresent(String.self , forKey: .pageUrl )
        zipUrl  = try values.decodeIfPresent(String.self , forKey: .zipUrl  )
    }
    
    init() {
        
    }
}

struct PullRequests: Codable {
    
    var id      : String? = nil
    var title   : String? = nil
    var pageUrl : String? = nil
    var zipUrl  : String? = nil
    
    enum CodingKeys: String, CodingKey {
        
        case id      = "id"
        case title   = "title"
        case pageUrl = "page_url"
        case zipUrl  = "zip_url"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id      = try values.decodeIfPresent(String.self , forKey: .id      )
        title   = try values.decodeIfPresent(String.self , forKey: .title   )
        pageUrl = try values.decodeIfPresent(String.self , forKey: .pageUrl )
        zipUrl  = try values.decodeIfPresent(String.self , forKey: .zipUrl  )
    }
    
    init() {
        
    }
}
