//
//  GardenerPlantCCell.swift
//  plantR_ios
//
//  Created by Rabissoni on 22/02/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit

class GardenerPlantCCell: UICollectionViewCell {
    
    @IBOutlet var progressBar: UIProgressView!
    @IBOutlet var imageView: CIRoundedImageView!
    @IBOutlet var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
