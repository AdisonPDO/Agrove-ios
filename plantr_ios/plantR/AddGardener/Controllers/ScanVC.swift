//
//  ScanVC.swift
//  plantR_ios
//
//  Created by Boris Roussel on 26/08/2020.
//  Copyright © 2020 Rabissoni. All rights reserved.
//

import UIKit

class ScanVC: UIViewController {
    
    override func viewDidLoad() {
           super.viewDidLoad()
       }
    @IBAction func backTapped(_ sender: UIButton) {
        UserService.shared.splashFirstLoad = false
        self.dismiss(animated: true, completion: nil)
    }
}
