//
//  HeaderDashboardPictureCell.swift
//  plantR_ios
//
//  Created by Rabissoni on 25/03/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit

protocol HeaderDashboardPictureCellDelegate {
    func didDeletePicture(named: String)
}

class HeaderDashboardPictureCell: UICollectionViewCell {
    @IBOutlet var imagePicture: UIImageView!
    @IBOutlet var deletePicture: UIButton!
    
    var idPicture: String?
    
    var delegate: HeaderDashboardPictureCellDelegate?
    
    @IBAction func deletePictureTapped(_ sender: UIButton) {
        delegate?.didDeletePicture(named: idPicture!)
    }
}
