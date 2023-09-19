//
//  PopUpScanAddGardener.swift
//  plantR_ios
//
//  Created by Boris Roussel on 27/08/2020.
//  Copyright © 2020 Rabissoni. All rights reserved.
//

import UIKit


class PopUpScanAddGardenerVC: UIViewController {

    @IBOutlet weak var lAddGardenerTitle: UILabel!
    @IBOutlet weak var lAddGardenerContent: UILabel!
    
    var subscribe: Bool = false
  
    
    override func viewDidLoad() {
        self.lAddGardenerTitle.text = NSLocalizedString("add_a_planter", comment: "add_a_planter")
        self.lAddGardenerContent.text = NSLocalizedString("to_track_a_planter,_please_scan_the_QR_Code_located_on_it", comment: "to_track_a_planter,_please_scan_the_QR_Code_located_on_it")
//        if (subscribe) {
//            self.lAddGardenerTitle.text = NSLocalizedString("subscribe_to_a_planter", comment: "subscribe_to_a_planter")
//            self.lAddGardenerContent.text = NSLocalizedString("to_track_a_planter,_please_scan_the_QR_Code_located_on_it", comment: "to_track_a_planter,_please_scan_the_QR_Code_located_on_it")
//        } else {
//            self.lAddGardenerTitle.text = NSLocalizedString("add_a_planter", comment: "add_a_planter")
//            self.lAddGardenerContent.text = NSLocalizedString("to_track_a_planter,_please_scan_the_QR_Code_located_on_it", comment: "to_track_a_planter,_please_scan_the_QR_Code_located_on_it")
//
//        }
    }
    
    @IBAction func scanTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "goToScannerVC", sender: nil)
    }
    
    @IBAction func dismissTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
