//
//  PlayerCollectionViewCell.swift
//  Tobydi
//
//  Created by Muhammad Abdullah on 11/01/2019.
//  Copyright © 2019 Muhammad Abdullah. All rights reserved.
//

import UIKit
class PlayerCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var musicImage: UIImageView!
    
    @IBOutlet weak var musicTitle: UILabel!
    
    @IBOutlet weak var heartButtonPressed: UIButton!
    @IBOutlet weak var musicArtist: UILabel!
       
    
    override func awakeFromNib() {
        musicImage.layer.cornerRadius = 10
        musicImage.layer.masksToBounds = true
    }
}
