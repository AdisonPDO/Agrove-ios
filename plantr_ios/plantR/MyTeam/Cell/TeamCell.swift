//
//  TeamCell.swift
//  plantR_ios
//
//  Created by Boris Roussel on 28/08/2020.
//  Copyright © 2020 Rabissoni. All rights reserved.
//

import UIKit

protocol TeamCVCellDelegate: class {
    func didDeleteOwnerButton(userId: String)
}

class TeamCellCVC: UICollectionViewCell {
    
    var uid = ""
    weak var delegate: TeamCVCellDelegate?

    @IBOutlet weak var imageProfil: CIRoundedImageView!
    @IBOutlet weak var name: UILabel!
    
    @IBAction func deleteOwnerTapped(_ sender: UIButton) {
        delegate?.didDeleteOwnerButton(userId: self.uid)
    }
}
