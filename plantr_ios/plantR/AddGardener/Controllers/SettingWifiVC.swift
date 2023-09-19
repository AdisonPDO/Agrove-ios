//
//  SettingWifiVC.swift
//  plantR_ios
//
//  Created by Rabissoni on 18/01/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit

class SettingWifiVC: UIViewController {

    @IBOutlet var wifiLabel: UITextField!
    @IBOutlet weak var backButton: UIButton!
    
    var activeBack = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backButton.isHidden = !activeBack
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*if segue.identifier == StoryboardSegue.AddGardener.goToWifiPassword.rawValue {
            let vc = segue.destination as! SettingPasswordVC
            vc.delegate = self
            vc.wifiName = wifiLabel.text
        } else if segue.identifier == StoryboardSegue.AddGardener.goToBluetooth.rawValue {
            let vc = segue.destination as! ConnexionBluetoothVC
            vc.passwordName = sender as? String
            vc.wifiName = wifiLabel.text
        }*/
    }
    
    @IBAction func backTapped(_ sender: Any) {
         self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension SettingWifiVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension SettingWifiVC: SettingPasswordVCDelegate {
    
    func didEnterPassword(_ password: String) {
/*        dismiss(animated: true) {
            self.perform(segue: StoryboardSegue.AddGardener.goToBluetooth, sender: password)
        }*/
    }
}
