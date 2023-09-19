//
//  UIViewController+Extension.swift
//  plantR_ios
//
//  Created by Rabissoni on 17/01/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func popOKAlertController(title: String, message: String? = nil, okHandler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: okHandler))
        alert.view.tintColor = Styles.PlantRMainGreen
        present(alert, animated: true, completion: nil)
    }
    
}
