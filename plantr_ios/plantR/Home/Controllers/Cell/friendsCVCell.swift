//
//  friendsCVCell.swift
//  plantR_ios
//
//  Created by Boris Roussel on 22/03/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit

protocol FriendsCVCellDelegate: class {
    func didDeleteFriendButton(gardenerId: String)
}

class FriendsCVCell: UICollectionViewCell {
    
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var profileImageView: CIRoundedImageView!
    @IBOutlet var waitingDataActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var profileStackView: UIStackView!
    @IBOutlet var deletedButton: UIButton!
    
    var gardenerId: String?
    
    weak var delegate: FriendsCVCellDelegate?
    
    @IBAction func deleteFriendTapped(_ sender: UIButton) {
        delegate?.didDeleteFriendButton(gardenerId: self.gardenerId!)
    }
    
    
}
