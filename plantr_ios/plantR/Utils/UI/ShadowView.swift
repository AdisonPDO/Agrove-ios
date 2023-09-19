//
//  ShadowView.swift
//  plantR_ios
//
//  Created by Rabissoni on 21/02/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit

class ShadowView: UIView {
    
    override func awakeFromNib() {
        self.layoutIfNeeded()
        
        layer.shadowOffset = CGSize.zero
        layer.shadowColor = UIColor(red: 0.83, green: 0.9, blue: 0.9, alpha: 1).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 6
    }
}
