//
//  AllTaskTVC.swift
//  plantR_ios
//
//  Created by Mathieu Rabissoni on 17/04/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit

class AllTaskTVC: UITableViewCell {

    @IBOutlet var titleTaskLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    
    var id: Int?
    var task: GardenerTaskModelToAllTasks?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
