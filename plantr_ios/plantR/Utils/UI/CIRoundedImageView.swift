//
//  CornerRaduisIV.swift
//  plantR_ios
//
//  Created by Rabissoni on 07/02/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit

class ImageViewRoundSubViews: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()

        let radius: CGFloat = self.bounds.size.width// / 2.0

        self.layer.cornerRadius = radius
    }
}


class CIRoundedImageView: UIImageView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        
        self.layoutIfNeeded()
        layer.cornerRadius = self.frame.height / 2.0
        layer.masksToBounds = true
    }
}

class CornerImageView: UIImageView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        
        self.layoutIfNeeded()
        layer.cornerRadius = self.frame.height / 10.0
        layer.masksToBounds = true
    }
}
