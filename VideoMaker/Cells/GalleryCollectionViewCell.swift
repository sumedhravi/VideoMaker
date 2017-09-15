//
//  GalleryCellCollectionViewCell.swift
//  VideoMaker
//
//  Created by Sumedh Ravi on 13/09/17.
//  Copyright © 2017 Sumedh Ravi. All rights reserved.
//

import UIKit

class GalleryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var selectionImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionImage.image = UIImage(named:"SelectionTick")
        self.selectionImage.layer.cornerRadius = 15
        self.selectionImage.clipsToBounds = true
    }

}
