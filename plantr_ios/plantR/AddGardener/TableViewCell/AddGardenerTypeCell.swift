//
//  AddGardenerTypeCell.swift
//  plantR_ios
//
//  Created by Boris Roussel on 25/05/2021.
//  Copyright © 2021 Agrove. All rights reserved.
//

import UIKit

protocol AddGardenerTypeDelegate: class {
    func didSelectType(type: String)
}

class AddGardenerTypeCell: UITableViewCell {
    
    @IBOutlet var ivType: UIImageView!
    @IBOutlet var lTitleCard: UILabel!
    @IBOutlet var lDescription: UILabel!
    
    weak var delegate: AddGardenerTypeDelegate?
    
    var type: String?
    
    @IBAction func SelectButtonType(_ sender: UIButton) {
        if let type = self.type {
            print("SELECT \(type)")
            delegate?.didSelectType(type: type)
        }
    }
}
