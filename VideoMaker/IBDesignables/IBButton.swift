//
//  IBButton.swift
//  VideoMaker
//
//  Created by Sumedh Ravi on 21/09/17.
//  Copyright © 2017 Sumedh Ravi. All rights reserved.
//

import UIKit

@IBDesignable

class IBButton: UIButton {

    @IBInspectable var borderColor: UIColor = UIColor.white {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }

}
