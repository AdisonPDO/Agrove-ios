//
//  SuccessAddGardenerVC.swift
//  plantR_ios
//
//  Created by Boris Roussel on 02/09/2020.
//  Copyright © 2020 Rabissoni. All rights reserved.
//

import UIKit

class SuccessAddGardenerVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func nextTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "goToSetGardener", sender: nil)
    }
    
}
