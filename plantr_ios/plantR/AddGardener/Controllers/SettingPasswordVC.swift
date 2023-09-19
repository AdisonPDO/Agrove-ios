//
//  SettingPasswordVC.swift
//  plantR_ios
//
//  Created by Rabissoni on 22/01/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit

protocol SettingPasswordVCDelegate: class {
    func didEnterPassword(_ password: String)
}

class SettingPasswordVC: UIViewController {
    
    @IBOutlet var wifiDetectedLabel: UILabel!
    @IBOutlet var passwordWifiLabel: UITextField!
    
    weak var delegate: SettingPasswordVCDelegate?
    var wifiName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wifiDetectedLabel.text = "Mot de passe du réseau: \(wifiName!)"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func backTapped(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        if passwordWifiLabel.text == "" {
            self.popOKAlertController(title: "Remplisser le champs mot de passe")
            return
        }
        delegate?.didEnterPassword(passwordWifiLabel.text!)
    }
}

extension SettingPasswordVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
        
    }
}
