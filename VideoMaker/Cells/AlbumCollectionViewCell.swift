//
//  AlbumCollectionViewCell.swift
//  VideoMaker
//
//  Created by Sumedh Ravi on 25/09/17.
//  Copyright © 2017 Sumedh Ravi. All rights reserved.
//

import UIKit

class AlbumCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var videoImage: UIImageView!
    
    @IBOutlet weak var videoDuration: UILabel!
    
    
    @IBOutlet weak var playImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.playImage.alpha = 0.5
        // Initialization code
    }

}
