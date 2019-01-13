//
//  youTube.swift
//  Tobydi
//
//  Created by Muhammad Abdullah on 13/01/2019.
//  Copyright © 2019 Muhammad Abdullah. All rights reserved.
//

import Foundation

struct yt :Decodable{
    let kind:String
    let regionCode:String
    let items:[items]
}
struct items:Decodable {
    let etag:String?
    let snippet:snippet
    let id:id
    
    
}
struct snippet:Decodable {
    let title:String?
    let thumbnails:thumbnails
    
}
struct id:Decodable {
    let videoId:String!
}
struct thumbnails:Decodable {
    let high:high!
}
struct high:Decodable {
    let url:String!
}