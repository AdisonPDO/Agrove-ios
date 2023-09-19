//
//  PopVC.swift
//  plantR_ios
//
//  Created by Boris Roussel on 01/09/2020.
//  Copyright © 2020 Rabissoni. All rights reserved.
//

import UIKit

class PopVC: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
    }
    
}

extension PopVC: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}
