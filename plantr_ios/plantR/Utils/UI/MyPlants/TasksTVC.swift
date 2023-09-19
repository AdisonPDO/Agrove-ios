//
//  TasksTVC.swift
//  plantR_ios
//
//  Created by Mathieu Rabissoni on 03/05/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit

class TasksTVC: UITableViewCell {

    @IBOutlet weak var tasksImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
