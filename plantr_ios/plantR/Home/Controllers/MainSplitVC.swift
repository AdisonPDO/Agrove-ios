//
//  MainSplitVC.swift
//  plantR_ios
//
//  Created by Rabissoni on 07/02/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit

class MainSplitVC: UISplitViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
    }
     
}

extension MainSplitVC: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}
