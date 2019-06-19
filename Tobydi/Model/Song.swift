//
//  Song.swift
//  Tobydi
//
//  Created by Muhammad Abdullah on 16/06/2019.
//  Copyright © 2019 Muhammad Abdullah. All rights reserved.
//

import Foundation
import UIKit
struct Song {
    var songName:String?
    var songUrl:String?
    var songImages:String?
    var downLoadedURL:String?
    
    init(songName: String, songUrl:String, songImages:String, downloadURL:String) {
        self.downLoadedURL = downloadURL
        self.songImages = songImages
        self.songName = songName
        self.songUrl = songUrl
    }
    
}
