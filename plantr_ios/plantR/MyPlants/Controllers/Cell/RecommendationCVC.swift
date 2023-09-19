//
//  RecommendationCVC.swift
//  plantR_ios
//
//  Created by Mathieu Rabissoni on 08/04/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit

protocol RecommendationCVCDelegate: class {
    func didSelectInfoPlantButton(keyPlant: InfosPlants)
}

class RecommendationCVC: UICollectionViewCell {
    
    @IBOutlet weak var imageViewPlant: UIImageView!
    @IBOutlet weak var seasonLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
 
    var dictPlant: InfosPlants?
    var plantUID: String?
    
    weak var delegate: RecommendationCVCDelegate?

    @IBAction func SelectInfoPlantTapped(_ sender: UIButton) {
        delegate?.didSelectInfoPlantButton(keyPlant: dictPlant!)
    }
    
}
