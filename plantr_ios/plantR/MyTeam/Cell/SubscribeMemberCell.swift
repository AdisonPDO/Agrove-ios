//
//  SubscribeMemberCell.swift
//  plantR_ios
//
//  Created by Boris Roussel on 05/02/2021.
//  Copyright © 2021 Agrove. All rights reserved.
//

import Foundation
import UIKit

protocol SubscribeMemberCellDelegate: class {
    func didDeleteSubscribeButton(userId: String, name: String)
    func didAddSubscribeButton(userId: String, name: String)
}

class SubscribeMemberCell: UITableViewCell {
    
    weak var delegate: SubscribeMemberCellDelegate?
    
    var uid = ""
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ivUser: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func AddButton(_ sender: UIButton) {
        delegate?.didAddSubscribeButton(userId: self.uid, name: self.nameLabel.text ?? "")
    }
    
    @IBAction func DeleteButton(_ sender: UIButton) {
        delegate?.didDeleteSubscribeButton(userId: self.uid, name: self.nameLabel.text ?? "")
    }
}

