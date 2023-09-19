//
//  HomeNC.swift
//  plantR_ios
//
//  Created by Rabissoni on 21/01/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit

class AddGardenerNC: UINavigationController {
    
    var dismissDelegate: DismissDelegate?
    var addGardener: Bool = false
    var subscribe: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (addGardener) {
            let vc = UIStoryboard(name: "AddGardener", bundle: nil).instantiateViewController(withIdentifier: "StartAddGardenerSelectType")
            self.setViewControllers([vc], animated: true)
        } else {
            let vc = UIStoryboard(name: "AddGardener", bundle: nil).instantiateViewController(withIdentifier: "PopUpScanAddGardenerVC") as! PopUpScanAddGardenerVC
            vc.subscribe = subscribe
            self.setViewControllers([vc], animated: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.dismissDelegate?.didDismiss()
    }
}
