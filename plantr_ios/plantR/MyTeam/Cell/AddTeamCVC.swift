//
//  AddTeamCVC.swift
//  plantR_ios
//
//  Created by Boris Roussel on 28/08/2020.
//  Copyright © 2020 Rabissoni. All rights reserved.
//

import UIKit

protocol AddTeamCVCDelegate: class {
    func didAddButton()
}

class AddTeamCVC: UICollectionViewCell {
    
    weak var delegate: AddTeamCVCDelegate?
    
    @IBAction func addTeamTapped(_ sender: UIButton) {
        delegate?.didAddButton()
    }
}
