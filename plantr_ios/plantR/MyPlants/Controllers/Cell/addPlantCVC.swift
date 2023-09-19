//
//  addPlantCVC.swift
//  plantR_ios
//
//  Created by Mathieu Rabissoni on 08/04/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit

enum WishlistState {
    case planting
    case sowing
    case twice
    case none
}

class AddPlantCVC: UICollectionViewCell {
    
    @IBOutlet weak var imageViewPlant: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var vInfo: CornerRaduisV!
    @IBOutlet weak var stateInfoLabel: UILabel!
    
    
    var state = WishlistState.none
}
