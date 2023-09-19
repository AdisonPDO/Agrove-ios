//
//  WhichSpecificTypeCVC.swift
//  plantR_ios
//
//  Created by Boris Roussel on 25/05/2021.
//  Copyright © 2021 Agrove. All rights reserved.
//

import UIKit

enum SizeSelectingType {
    case kitMural
    case kitCapteur
    case kitCleEnMain
    case kitParcelle
    case potPetit
    case potMoyen
    case potGrand
    case jardinierePetite
    case jardiniereMoyen
    case jardiniereGrand
    case carrePetit
    case carreMoyen
    case carreGrand
}

class SelectingAgroveTypeCVC: UICollectionViewCell {
    @IBOutlet var ivType: UIImageView!
    @IBOutlet var lTitle: UILabel!
    
    var type: SizeSelectingType?
}

class SizeSelectingTypeCVC: UICollectionViewCell {
    @IBOutlet var ivType: UIImageView!
    @IBOutlet var lTitle: UILabel!
    @IBOutlet var ldesc: UILabel!
    
    var type: SizeSelectingType?
}
