//
//  PlantRTextField.swift
//  plantR_ios
//
//  Created by Rabissoni on 17/01/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import  UIKit

class PlantRTextField: UITextField {
    
    private enum Consts {
        static let HeightRatio: CGFloat = 1.5
    }
    
    override var intrinsicContentSize: CGSize {
        let parentSize = super.intrinsicContentSize
        return CGSize(width: parentSize.width, height: parentSize.height * Consts.HeightRatio)
    }
}
