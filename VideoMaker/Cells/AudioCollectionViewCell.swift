//
//  AudioCollectionViewCell.swift
//  VideoMaker
//
//  Created by Sumedh Ravi on 13/09/17.
//  Copyright © 2017 Sumedh Ravi. All rights reserved.
//

import UIKit

class AudioCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var audioImage: UIImageView!
    
    @IBOutlet weak var audioName: UILabel!
    
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var cellView: UIView!
    let cellImageSize = 80
    var isPlaying = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        self.audioImage.layer.cornerRadius = CGFloat(cellImageSize/2)
        self.audioImage.clipsToBounds = true
        durationLabel.isHidden = true

        // Initialization code
    }

}
