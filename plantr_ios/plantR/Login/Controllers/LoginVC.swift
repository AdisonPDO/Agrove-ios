//
//  LoginVC.swift
//  plantR_ios
//
//  Created by Rabissoni on 17/01/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func goToConnectTapped(_ sender: UIButton) {
        guard emailTextField.text != "" && passwordTextField.text != "" else {
            self.popOKAlertController(title: NSLocalizedString("a_content_is_empty", comment: "a content is empty"))
            return
        }
        activityIndicator.startAnimating()
        sender.isEnabled = false
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (_, error) in
            sender.isEnabled = true
            self.activityIndicator.stopAnimating()
            if let error = error {
                self.popOKAlertController(title: error.localizedFirebaseAuthDescription)
                return
            }
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func forgetPasswordTapped(_ sender: Any) {
        let alertController = UIAlertController(title: NSLocalizedString("please_enter_your_email_address", comment: "please enter your email address"), message: nil, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = NSLocalizedString("mail", comment: "mail")
            textField.keyboardType = .emailAddress
        })
        alertController.addAction(UIAlertAction(title: NSLocalizedString("send", comment: "send"), style: .default, handler: { _ in
            Auth.auth().sendPasswordReset(withEmail: (alertController.textFields?.first?.text)!) { (error) in
                if let error = error {
                    self.popOKAlertController(title: error.localizedDescription)
                } else {
                    self.popOKAlertController(title: NSLocalizedString("an_email_has_been_sent_to_you", comment: "an email has been sent to you"))
                }
            }
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"), style: .cancel, handler: nil))
        alertController.view.tintColor = Styles.PlantRMainGreen
        self.present(alertController, animated: true, completion: nil)
    }
}

extension LoginVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
}
