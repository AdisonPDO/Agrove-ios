//
//  SettingNameGardenerVC.swift
//  plantR_ios
//
//  Created by Rabissoni on 21/01/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit
import Firebase

class SettingNameGardenerVC: UIViewController {
    
    @IBOutlet var nameGardernerTextField: UITextField!
    
    var gardenerRepository: GardenerRepository!
    var gardenerTransformer: GardenerTransformer!
    var currentGardener: String!
    private var currentUser: User!
    var gardenerName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUser = Auth.auth().currentUser
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func finishTapped(_ sender: UIButton) {
        sender.isEnabled = false
        guard self.nameGardernerTextField.text! != "" else {
            sender.isEnabled = true
            self.popOKAlertController(title: NSLocalizedString("give_your_planter_a_name", comment: "give your planter a name"))
            return
        }
        gardenerName = self.nameGardernerTextField.text!
        self.performSegue(withIdentifier: "goToSetAddress", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SettingCityGardenerVC {
            destination.gardenerName = self.gardenerName
        }
    }
}

extension SettingNameGardenerVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
        
    }
}
