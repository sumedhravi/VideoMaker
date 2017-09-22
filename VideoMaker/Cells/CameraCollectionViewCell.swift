//
//  CameraCollectionViewCell.swift
//  VideoMaker
//
//  Created by Sumedh Ravi on 20/09/17.
//  Copyright © 2017 Sumedh Ravi. All rights reserved.
//

import UIKit

class CameraCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cellImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.cellImage.contentMode = .scaleAspectFill
        
    }

    @IBOutlet weak var deleteButton: UIButton!
}
