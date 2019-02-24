//
//  Shahzam.swift
//  Tobydi
//
//  Created by Muhammad Abdullah on 23/02/2019.
//  Copyright © 2019 Muhammad Abdullah. All rights reserved.
//

import Foundation
struct Shahzam:Decodable {
    let body:body!
}
struct body:Decodable {
    let audio_clips:[audio_clips]
}
struct audio_clips:Decodable {
    let id:String!
    let title:String!
    let urls:urls!
}
struct urls:Decodable {
    let high_mp3:String!
    let wave_img:String!
}
