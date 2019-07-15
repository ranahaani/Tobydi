//
//  soundclod
//  Tobydi
//
//  Created by Muhammad Abdullah on 13/01/2019.
//  Copyright © 2019 Muhammad Abdullah. All rights reserved.
//

import Foundation

struct soundclod :Decodable{
    let data:[data]
}
struct data:Decodable {
    let pictures:pictures?
    let name:String?
    let url:String?
    
}

struct pictures:Decodable {
    let medium:String?
}


struct getsoundclodDownloadable:Decodable {
    let formats:[formats]!
}
struct formats:Decodable {
    let url:String!
}
