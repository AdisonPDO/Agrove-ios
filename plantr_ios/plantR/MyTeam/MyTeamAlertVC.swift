//
//  MyTeamAlertVC.swift
//  plantR_ios
//
//  Created by Adison Pereira de oliveira on 25/02/2022.
//  Copyright © 2022 Agrove. All rights reserved.
//

import Foundation
import UIKit

class MyTeamAlertVC : UIViewController{
    
    @IBOutlet var leaveButton: UIButton!
    
    @IBAction func leaveTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
