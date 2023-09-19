//
//  MySubscribe.swift
//  plantR_ios
//
//  Created by Boris Roussel on 02/09/2020.
//  Copyright © 2020 Rabissoni. All rights reserved.
//

import UIKit

class MySubscribeVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        print("SUBCRIBE")
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
