//
//  PopAlertServices.swift
//  plantR_ios
//
//  Created by Adison Pereira de oliveira on 04/05/2022.
//  Copyright © 2022 Agrove. All rights reserved.
//

import Foundation
import UIKit

class PopAlertServices {
    func pop(view : UIViewController, str: String?, title: String, isDismiss: Bool){
        if(str != nil){
            view.popOKAlertController(title: NSLocalizedString(title , comment: title), message: NSLocalizedString(str! , comment: str!))
        }else{
            view.popOKAlertController(title: NSLocalizedString(title , comment: title))
        }
        if(isDismiss){
            view.dismiss(animated: true, completion: nil)
        }
    }
}
