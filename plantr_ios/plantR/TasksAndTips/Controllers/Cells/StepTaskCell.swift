//
//  StepTaskCell.swift
//  plantR_ios
//
//  Created by Boris Roussel on 04/05/2021.
//  Copyright © 2021 Agrove. All rights reserved.
//

import UIKit

class StepTaskCell: UITableViewCell {

    @IBOutlet var lStep: UILabel!
    @IBOutlet var lStepInfo: UILabel!
    @IBOutlet var ivStep: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
