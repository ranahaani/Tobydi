//
//  iTunes
//  Tobydi
//
//  Created by Muhammad Abdullah on 13/01/2019.
//  Copyright © 2019 Muhammad Abdullah. All rights reserved.
//

import Foundation

struct iTunes :Decodable{
    let resultCount:Int
    let results:[results]
}
struct results:Decodable {
    let artistName:String?
    let trackName:String?
    let previewUrl:String?
    let artworkUrl100:String?
    
    
}
